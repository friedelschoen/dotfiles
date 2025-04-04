package main

import (
	"bytes"
	"errors"
	"fmt"
	"io"
	"maps"
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

func (ev *Evaluator) interpolate(obj Object, scope map[string]Object) (Object, error) {
	str := obj.value.(string)
	if str == "" {
		return obj, nil
	}
	if str[0] == '@' && str != "@multiline" {
		varName := str[1:]
		replacement, found := scope[varName]
		if !found {
			return Object{}, fmt.Errorf("%s: undefined variable: %s", obj.position(), varName)
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
			return Object{}, fmt.Errorf("%s: unmatched {{ in string: %s", obj.position(), str)
		}
		varName := str[2:endIdx]
		replacement, found := scope[varName]
		if !found {
			return Object{}, fmt.Errorf("%s: undefined variable: %s", obj.position(), varName)
		}
		replacementStr, valid := replacement.value.(string)
		if !valid {
			return Object{}, fmt.Errorf("%s: variable %s must be a string, got %T", obj.position(), varName, replacement)
		}
		builder.WriteString(replacementStr)
		str = str[endIdx+2:]
	}
	builder.WriteString(str)
	obj.value = builder.String()
	return obj, nil
}

func copyMapKeep[K comparable, V Object](dest map[K]V, source map[K]V) {
	for k, v := range source {
		_, ok := dest[k]
		if !ok {
			dest[k] = v
		}
	}
}

func (ev *Evaluator) resolve(ast Object, scope map[string]Object) (Object, error) {
	scope = maps.Clone(scope)
	maps.Copy(scope, ast.defines)
	for len(ast.includes) > 0 || len(ast.extends) > 0 {
		var otherast Object
		if len(ast.includes) > 0 {
			inclpath := ast.includes[0]
			ast.includes = ast.includes[1:]
			var err error
			otherast, err = parseFile(inclpath, inclpath.value.(string), &ast)
			if err != nil {
				return Object{}, err
			}
		} else if len(ast.extends) > 0 {
			extname := ast.extends[0]
			ast.extends = ast.extends[1:]
			var ok bool
			otherast, ok = scope[extname.value.(string)]
			if !ok {
				return Object{}, fmt.Errorf("%s: not in scope: %s", extname.position(), extname.value.(string))
			}
		}
		copyMapKeep(ast.defines, otherast.defines)
		ast.includes = append(ast.includes, otherast.includes...)
		ast.extends = append(ast.extends, otherast.extends...)

		if len(otherast.defines) > 0 {
			scope = maps.Clone(scope)
			copyMapKeep(scope, otherast.defines)
		}

		object := ast.value.(map[string]Object)
		otherobject := otherast.value.(map[string]Object)
		copyMapKeep(object, otherobject)
	}

	switch value := ast.value.(type) {
	case map[string]Object:
		if !ev.Serial {
			var (
				wg   sync.WaitGroup
				mu   sync.Mutex
				errs []error
			)
			for k, v := range value {
				wg.Add(1)
				go func() {
					defer wg.Done()
					val, err := ev.resolve(v, scope)
					mu.Lock()
					value[k] = val
					errs = append(errs, err)
					mu.Unlock()
				}()
			}
			wg.Wait()
			if err := errors.Join(errs...); err != nil {
				return Object{}, err
			}
		} else {
			var err error
			for k, v := range value {
				value[k], err = ev.resolve(v, scope)
				if err != nil {
					return Object{}, err
				}
			}
		}
		if _, ok := value["@output"]; ok && !ev.NoEvalOutput {
			return ev.output(ast)
		}
	case []Object:
		if !ev.Serial {
			var (
				wg   sync.WaitGroup
				mu   sync.Mutex
				errs []error
			)
			for i, elem := range value {
				wg.Add(1)
				go func() {
					defer wg.Done()
					val, err := ev.resolve(elem, scope)
					mu.Lock()
					value[i] = val
					errs = append(errs, err)
					mu.Unlock()
				}()
			}
			wg.Wait()
			if err := errors.Join(errs...); err != nil {
				return Object{}, err
			}
		} else {
			var err error
			for i, elem := range value {
				value[i], err = ev.resolve(elem, scope)
				if err != nil {
					return Object{}, err
				}
			}
		}
		if len(value) > 0 {
			if head, ok := value[0].value.(string); ok && head == "@multiline" {
				var builder strings.Builder
				for i, elem := range value[1:] {
					selem, ok := elem.value.(string)
					if !ok {
						return Object{}, fmt.Errorf("%s: non-string in @multiline-array: %T", elem.position(), elem.value)
					}
					if i > 0 {
						builder.WriteByte('\n')
					}
					builder.WriteString(selem)
				}
				ast.value = builder.String()
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
