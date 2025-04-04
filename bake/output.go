package main

import (
	"encoding/hex"
	"fmt"
	"hash/fnv"
	"io"
	"maps"
	"os"
	"os/exec"
	"path"
	"slices"
	"strconv"
	"strings"
	"time"
)

func hashValue(w io.Writer, obj Object) {
	switch value := obj.value.(type) {
	case map[string]Object:
		fmt.Fprint(w, "map")
		keys := slices.Collect(maps.Keys(value))
		slices.Sort(keys)
		for _, k := range keys {
			w.Write([]byte(k))
			hashValue(w, value[k])
		}
	case []Object:
		fmt.Fprint(w, "list")
		for i, elem := range value {
			fmt.Fprint(w, i)
			hashValue(w, elem)
		}
	default: /* string, bool, float64 */
		fmt.Fprintf(w, "%T", value)
		fmt.Fprint(w, value)
	}
}

func encodeEnviron(obj Object, root bool) (string, error) {
	switch value := obj.value.(type) {
	case string:
		return value, nil
	case float64:
		return strconv.FormatFloat(value, 'f', -1, 64), nil
	case bool:
		if value {
			return "1", nil
		}
		return "0", nil
	case []Object:
		if !root {
			return "", fmt.Errorf("%s: unable to encode nested %T", obj.position(), value)
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
	case map[string]Object:
		if !root {
			return "", fmt.Errorf("%s: unable to encode nested %T", obj.position(), value)
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
		return "", fmt.Errorf("%s: unable to encode %T", obj.position(), value)
	}
}

func (ev *Evaluator) output(result Object) (Object, error) {
	hashlib := fnv.New64()
	hashValue(hashlib, result)
	hashstr := hex.EncodeToString(hashlib.Sum(nil))

	names := make([]string, 0)
	for node := &result; node != nil; node = node.parent {
		if mapv, ok := node.value.(map[string]Object); ok {
			if nameAny, ok := mapv["@name"]; ok {
				if name, ok := nameAny.value.(string); ok && (len(names) == 0 || names[len(names)-1] != name) {
					names = append(names, name)
				}
			}
		}
	}

	if len(names) >= 2 {
		ev.Edges = append(ev.Edges, [2]string{names[1], names[0]})
	}

	cwd, _ := os.Getwd()
	outdir := path.Join(cwd, ev.CacheDir, hashstr)
	if _, err := os.Stat(outdir); (ev.DryRun || err == nil) && !ev.Force {
		return Object{value: outdir}, nil
	}

	start := time.Now()

	os.RemoveAll(outdir)
	success := false
	defer func() {
		if !success {
			os.RemoveAll(outdir)
		}
	}()

	values := result.value.(map[string]Object)

	install, ok := values["@output"].value.(string)
	if !ok {
		return Object{}, fmt.Errorf("%s: @output must be a string", values["@output"].position())
	}

	interpreter := ev.Interpreter
	if interpreterAny, ok := values["@interpreter"]; ok {
		if str, ok := interpreterAny.value.(string); ok {
			interpreter = str
		} else {
			return Object{}, fmt.Errorf("%s: @interpreter must be a string", interpreterAny.position())
		}
	}

	builddir, err := os.MkdirTemp("", "bake-")
	if err != nil {
		return Object{}, err
	}
	defer os.RemoveAll(builddir)
	environ := append(os.Environ(), "out="+outdir)
	for key, value := range values {
		if key != "" && key[0] == '$' {
			enc, err := encodeEnviron(value, true)
			if err != nil {
				return Object{}, err
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
		return Object{}, fmt.Errorf("%s: %w\n", values["@output"].position(), err)
	}

	dur := time.Since(start).Round(time.Millisecond)
	if len(names) > 0 {
		fmt.Fprintf(os.Stderr, "%s %s (%v)\n", hashstr, strings.Join(names, " > "), dur)
	} else {
		fmt.Fprintf(os.Stderr, "%s (%v)\n", hashstr, dur)
	}

	success = true
	return Object{value: outdir}, nil
}
