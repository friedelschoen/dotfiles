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

func hashValue(hashlib io.Writer, value any) {
	switch value := value.(type) {
	case *Object:
		keys := slices.Collect(maps.Keys(value.values))
		slices.Sort(keys)
		for _, k := range keys {
			hashlib.Write([]byte(k))
			hashValue(hashlib, value.values[k])
		}
	case []any:
		for _, elem := range value {
			hashValue(hashlib, elem)
		}
	default: /* string, bool, float64 */
		fmt.Fprint(hashlib, value)
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

func (ev *Evaluator) output(result *Object) (string, error) {
	hashlib := fnv.New64()
	hashValue(hashlib, result)
	hashstr := hex.EncodeToString(hashlib.Sum(nil))

	names := make([]string, 0)
	for node := result; node != nil; node = node.parent {
		if nameAny, ok := node.values["@name"]; ok {
			if name, ok := nameAny.(string); ok && (len(names) == 0 || names[len(names)-1] != name) {
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

	start := time.Now()

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
	defer os.RemoveAll(builddir)
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

	dur := time.Since(start).Round(time.Millisecond)
	if len(names) > 0 {
		fmt.Fprintf(os.Stderr, "%s %s (%v)\n", hashstr, strings.Join(names, " > "), dur)
	} else {
		fmt.Fprintf(os.Stderr, "%s (%v)\n", hashstr, dur)
	}

	success = true
	return outdir, nil
}
