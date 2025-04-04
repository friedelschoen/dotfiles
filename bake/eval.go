package main

import (
	"bytes"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"hash"
	"hash/crc64"
	"io"
	"maps"
	"os"
	"os/exec"
	"path"
	"slices"
	"strconv"
	"strings"
	"sync"
)

type Edge [2]string

type Evaluator struct {
	Force        bool
	DryRun       bool
	CacheDir     string
	LogDir       string
	Serial       bool
	Interpreter  string
	NoEvalOutput bool

	Edges []Edge
}

func (ev *Evaluator) interpolate(str string, scope map[string]any) (any, error) {
	if str == "" {
		return str, nil
	}
	if str[0] == '@' && str != "@multiline" {
		varName := str[1:]
		replacement, found := scope[varName]
		if !found {
			return nil, fmt.Errorf("undefined variable: %s", varName)
		}
		return ev.resolve(replacement, scope)
	}
	var builder strings.Builder
	for len(str) > 0 {
		startIdx := strings.Index(str, "{{")
		if startIdx == -1 {
			break
		}
		builder.WriteString(str[:startIdx])
		str = str[startIdx:]
		endIdx := strings.Index(str, "}}")
		if endIdx == -1 {
			return nil, fmt.Errorf("unmatched {{ in string: %s", str)
		}
		varName := str[2:endIdx]
		replacement, found := scope[varName]
		if !found {
			return nil, fmt.Errorf("undefined variable: %s", varName)
		}
		replacementStr, valid := replacement.(string)
		if !valid {
			return nil, fmt.Errorf("variable %s must be a string, got %T", varName, replacement)
		}
		builder.WriteString(replacementStr)
		str = str[endIdx+2:]
	}
	builder.WriteString(str)
	return builder.String(), nil
}

func copyMapKeep[K comparable, V any](dest map[K]V, source map[K]V) {
	for k, v := range source {
		_, ok := dest[k]
		if !ok {
			dest[k] = v
		}
	}
}

func (ev *Evaluator) resolve(ast any, scope map[string]any) (any, error) {
	switch ast := ast.(type) {
	case *Object:
		scope = maps.Clone(scope)
		maps.Copy(scope, ast.defines)
		for len(ast.includes) > 0 || len(ast.extends) > 0 {
			var otherast any
			if len(ast.includes) > 0 {
				inclpath := ast.includes[0]
				ast.includes = ast.includes[1:]
				var err error
				otherast, err = parseFile(inclpath, ast)
				if err != nil {
					return nil, err
				}
			} else if len(ast.extends) > 0 {
				extname := ast.extends[0]
				ast.extends = ast.extends[1:]
				var ok bool
				otherast, ok = scope[extname]
				if !ok {
					return nil, fmt.Errorf("not in scope: %s\n", extname)
				}
			}
			otherobject, ok := otherast.(*Object)
			if !ok {
				return nil, fmt.Errorf("@includes expects object")
			}
			copyMapKeep(ast.defines, otherobject.defines)
			copyMapKeep(ast.values, otherobject.values)
			ast.includes = append(ast.includes, otherobject.includes...)
			ast.extends = append(ast.extends, otherobject.extends...)

			if len(otherobject.defines) > 0 {
				scope = maps.Clone(scope)
				copyMapKeep(scope, otherobject.defines)
			}
		}
		if !ev.Serial {
			var (
				wg   sync.WaitGroup
				mu   sync.Mutex
				errs []error
			)
			for k, v := range ast.values {
				wg.Add(1)
				go func() {
					defer wg.Done()
					val, err := ev.resolve(v, scope)
					mu.Lock()
					ast.values[k] = val
					errs = append(errs, err)
					mu.Unlock()
				}()
			}
			wg.Wait()
			if err := errors.Join(errs...); err != nil {
				return nil, err
			}
		} else {
			var err error
			for k, v := range ast.values {
				ast.values[k], err = ev.resolve(v, scope)
				if err != nil {
					return nil, err
				}
			}
		}
		if _, ok := ast.values["@output"]; ok && !ev.NoEvalOutput {
			return ev.output(ast)
		}
		if unwrap, ok := ast.values["@"]; ok {
			return unwrap, nil
		}
	case []any:
		if !ev.Serial {
			var (
				wg   sync.WaitGroup
				mu   sync.Mutex
				errs []error
			)
			for i, elem := range ast {
				wg.Add(1)
				go func() {
					defer wg.Done()
					val, err := ev.resolve(elem, scope)
					mu.Lock()
					ast[i] = val
					errs = append(errs, err)
					mu.Unlock()
				}()
			}
			wg.Wait()
			if err := errors.Join(errs...); err != nil {
				return nil, err
			}
		} else {
			var err error
			for i, elem := range ast {
				ast[i], err = ev.resolve(elem, scope)
				if err != nil {
					return nil, err
				}
			}
		}
		if len(ast) > 0 {
			if head, ok := ast[0].(string); ok && head == "@multiline" {
				var builder strings.Builder
				for i, elem := range ast[1:] {
					selem, ok := elem.(string)
					if !ok {
						return nil, fmt.Errorf("non-string in @multiline-array: %T", elem)
					}
					if i > 0 {
						builder.WriteByte('\n')
					}
					builder.WriteString(selem)
				}
				return builder.String(), nil
			}
		}
	case string:
		return ev.interpolate(ast, scope)
	}
	return ast, nil
}

type PrefixWriter struct {
	Prefix string
	Writer io.Writer

	buf   bytes.Buffer
	start bool
}

func NewPrefixWriter(prefix string, w io.Writer) *PrefixWriter {
	return &PrefixWriter{
		Prefix: prefix,
		Writer: w,
		start:  true,
	}
}

func (pw *PrefixWriter) Write(p []byte) (n int, err error) {
	total := 0
	for len(p) > 0 {
		if pw.start {
			if _, err := pw.Writer.Write([]byte(pw.Prefix)); err != nil {
				return total, err
			}
			pw.start = false
		}

		i := bytes.IndexByte(p, '\n')
		if i == -1 {
			n, err := pw.Writer.Write(p)
			total += n
			return total, err
		}

		n, err := pw.Writer.Write(p[:i+1])
		total += n
		if err != nil {
			return total, err
		}

		p = p[i+1:]
		pw.start = true
	}

	return total, nil
}

func (ev *Evaluator) output(result *Object) (string, error) {
	hashlib := crc64.New(crc64.MakeTable(crc64.ECMA))
	enc := json.NewEncoder(hashlib)
	hashValue(hashlib, enc, result.values)
	hashstr := hex.EncodeToString(hashlib.Sum(nil))

	names := make([]string, 0)
	for node := result; node != nil; node = node.parent {
		if nameAny, ok := node.values["@name"]; ok {
			if name, ok := nameAny.(string); ok {
				names = append(names, name)
			}
		}
	}

	if len(names) >= 2 {
		ev.Edges = append(ev.Edges, [2]string{names[1], names[0]})
	}

	cwd, _ := os.Getwd()
	outdir := path.Join(cwd, ev.CacheDir, hashstr)
	if _, err := os.Stat(outdir); (ev.DryRun || err == nil) && !ev.Force {
		return outdir, nil
	}

	os.RemoveAll(outdir)
	success := false
	defer func() {
		if !success {
			fmt.Println("failed")
			os.RemoveAll(outdir)
		}
	}()

	install, ok := result.values["@output"].(string)
	if !ok {
		return "", fmt.Errorf("@output must be a string")
	}

	interpreter := ev.Interpreter
	if interpreterAny, ok := result.values["@interpreter"]; ok {
		if str, ok := interpreterAny.(string); ok {
			interpreter = str
		} else {
			return "", fmt.Errorf("@interpreter must be a string")
		}
	}

	builddir, err := os.MkdirTemp("", "bake-")
	if err != nil {
		return "", err
	}
	environ := append(os.Environ(), "out="+outdir)
	for key, value := range result.values {
		if key != "" && key[0] == '$' {
			enc, err := encodeEnviron(value, true)
			if err != nil {
				return "", err
			}
			environ = append(environ, key[1:]+"="+enc)
		}
	}

	logfile, err := os.Create(path.Join(ev.LogDir, hashstr+".log"))
	if err != nil {
		logfile = os.Stdout
	}
	logbuf := &RingBuffer{Content: make([]byte, 1024)}
	stdout := io.MultiWriter(logfile, logbuf)

	cmd := exec.Command(interpreter, "-e", "-c", install)
	cmd.Env = environ
	cmd.Dir = builddir
	cmd.Stdin = nil
	cmd.Stdout = stdout
	cmd.Stderr = stdout
	if err := cmd.Run(); err != nil {
		fmt.Fprintf(os.Stderr, "building %s failed: %v\n%s\n\n", hashstr, err, string(logbuf.Get()))
		return "", err
	}

	fmt.Fprint(os.Stderr, hashstr)
	if len(names) > 0 {
		fmt.Fprintf(os.Stderr, " %s\n", strings.Join(names, " > "))
	} else {
		fmt.Fprintln(os.Stderr)
	}

	success = true
	return outdir, nil
}

func hashValue(hashlib hash.Hash, encoder *json.Encoder, value any) {
	switch value := value.(type) {
	case *Object:
		keys := slices.Collect(maps.Keys(value.values))
		slices.Sort(keys)
		for _, k := range keys {
			hashlib.Write([]byte(k))
			hashValue(hashlib, encoder, value.values[k])
		}
	default:
		encoder.Encode(value)
	}
}

func encodeEnviron(value any, root bool) (string, error) {
	switch value := value.(type) {
	case string:
		return value, nil
	case float64:
		return strconv.FormatFloat(value, 'f', -1, 64), nil
	case bool:
		if value {
			return "1", nil
		}
		return "0", nil
	case []any:
		if !root {
			return "", fmt.Errorf("unable to encode nested %T", value)
		}
		var builder strings.Builder
		for i, elem := range value {
			if i > 0 {
				builder.WriteByte(' ')
			}
			enc, err := encodeEnviron(elem, false)
			if err != nil {
				return "", err
			}
			builder.WriteString(enc)
		}
		return builder.String(), nil
	case map[string]any:
		if !root {
			return "", fmt.Errorf("unable to encode nested %T", value)
		}
		var builder strings.Builder
		first := true
		for key, elem := range value {
			if !first {
				builder.WriteByte(' ')
			}
			first = false
			builder.WriteString(key)
			builder.WriteByte('=')
			enc, err := encodeEnviron(elem, false)
			if err != nil {
				return "", err
			}
			builder.WriteString(enc)
		}
		return builder.String(), nil
	default:
		return "", fmt.Errorf("unable to encode %T", value)
	}
}
