package main

import (
	"encoding/hex"
	"encoding/json"
	"fmt"
	"hash"
	"hash/crc64"
	"io"
	"maps"
	"os"
	"os/exec"
	"path"
	"path/filepath"
	"slices"
	"strconv"
	"strings"
)

type RingBuffer struct {
	Content []byte
	Index   int
	Size    int
}

func (b *RingBuffer) Write(p []byte) (int, error) {
	for _, chr := range p {
		b.Content[b.Index] = chr
		b.Index = (b.Index + 1) % len(b.Content)
		b.Size = min(b.Size+1, len(b.Content))
	}

	return len(p), nil
}

func (b *RingBuffer) Get() []byte {
	result := make([]byte, b.Size)
	for i := range b.Size {
		result[i] = b.Content[(i+b.Index)%len(b.Content)]
	}
	return result
}

/* Parser handles JSON parsing with support for includes and definitions. */
type Parser struct {
	dec *json.Decoder
	cwd string
}

/* interpolate replaces variables in strings using "@define" values. */
func (p *Parser) interpolate(value any, scope map[string]any) (any, error) {
	str, ok := value.(string)
	if !ok {
		return value, nil // No interpolation needed
	}
	if str == "" {
		return value, nil
	}

	if str[0] == '@' {
		varName := str[1:]
		replacement, found := scope[varName]
		if !found {
			return nil, fmt.Errorf("undefined variable: %s", varName)
		}
		return p.interpolate(replacement, scope)
	}

	if strings.HasPrefix(str, "./") {
		return path.Join(p.cwd, str), nil
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

/* parseValue parses a JSON value (object, array, or primitive). */
func (p *Parser) parseValue(scope map[string]any, dooutput bool) (any, error) {
	token, err := p.dec.Token()
	if err != nil {
		return nil, err
	}

	switch tok := token.(type) {
	case json.Delim:
		switch tok {
		case '{':
			return p.parseMap(scope, dooutput)
		case '[':
			return p.parseArray(scope, dooutput)
		}
	default:
		return tok, nil
	}

	return nil, fmt.Errorf("unexpected token: %v", token)
}

func hashValue(hashlib hash.Hash, encoder *json.Encoder, value any) {
	switch value := value.(type) {
	case map[string]any:
		keys := slices.Collect(maps.Keys(value))
		slices.Sort(keys)
		for _, k := range keys {
			hashlib.Write([]byte(k))
			hashValue(hashlib, encoder, value[k])
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

func (p *Parser) output(result map[string]any) (string, error) {
	hashlib := crc64.New(crc64.MakeTable(crc64.ECMA))
	enc := json.NewEncoder(hashlib)
	hashValue(hashlib, enc, result)
	hashstr := hex.EncodeToString(hashlib.Sum(nil))

	cwd, _ := os.Getwd()
	outdir := path.Join(cwd, "store", hashstr)
	if _, err := os.Stat(outdir); err == nil {
		return outdir, nil
	}

	os.RemoveAll(outdir)

	success := false
	defer func() {
		if !success {
			os.RemoveAll(outdir)
		}
	}()

	var install string
	switch outputValue := result["@output"].(type) {
	case string:
		install = outputValue
	case []any:
		var builder strings.Builder
		for i, elem := range outputValue {
			if i > 0 {
				builder.WriteByte('\n')
			}
			elemStr, ok := elem.(string)
			if !ok {
				return "", fmt.Errorf("@output expected string or string[], got %T in array", elem)
			}
			builder.WriteString(elemStr)
		}
		install = builder.String()
	default:
		return "", fmt.Errorf("@output must be a string")
	}

	interpreter := "sh"
	interpreterAny, ok := result["@interpreter"]
	if ok {
		interpreter, ok = interpreterAny.(string)
		if !ok {
			return "", fmt.Errorf("@interpreter must be a string")
		}
	}

	builddir, err := os.MkdirTemp("", "bake-")
	if err != nil {
		return "", err
	}

	environ := append(os.Environ(), "out="+outdir)
	for key, value := range result {
		if key == "" || key[0] != '$' {
			continue
		}

		key = key[1:]
		enc, err := encodeEnviron(value, true)
		if err != nil {
			return "", err
		}
		environ = append(environ, key+"="+enc)
	}

	os.MkdirAll("logs", 0755)
	logfile, err := os.Create(path.Join("logs", hashstr+".txt"))
	if err != nil {
		logfile = os.Stdout
	}

	logbuf := &RingBuffer{Content: make([]byte, 128)}
	stdout := io.MultiWriter(logfile, logbuf)

	cmd := exec.Command(interpreter, "-e", "-c", install)
	cmd.Env = environ
	cmd.Dir = builddir
	cmd.Stdin = nil
	cmd.Stdout = stdout
	cmd.Stderr = stdout
	if err := cmd.Run(); err != nil {
		fmt.Println(string(logbuf.Get()))
		return "", err
	}

	success = true
	return outdir, nil
}

/* parseMap parses a JSON object into map[string]any. */
func (p *Parser) parseMap(scope map[string]any, dooutput bool) (any, error) {
	result := make(map[string]any)

	for p.dec.More() {
		key, err := p.dec.Token()
		if err != nil {
			return nil, err
		}

		keyStr, ok := key.(string)
		if !ok {
			return nil, fmt.Errorf("expected string key, got %T", key)
		}

		switch keyStr {
		case "@define":
			value, err := p.parseValue(scope, false)
			if err != nil {
				return nil, err
			}

			defs, ok := value.(map[string]any)
			if !ok {
				return nil, fmt.Errorf("@define must be a map, got %T", value)
			}
			maps.Copy(scope, defs)

		case "@expand":
			value, err := p.parseValue(scope, true)
			if err != nil {
				return nil, err
			}

			name, ok := value.(string)
			if !ok {
				return nil, fmt.Errorf("@expand variable must be string, got %T", value)
			}
			exp, ok := scope[name]
			if !ok {
				return nil, fmt.Errorf("not in scope: %s", name)
			}
			expMap, ok := exp.(map[string]any)
			if !ok {
				return nil, fmt.Errorf("@expand must be a map, got %T", value)
			}
			maps.Copy(result, expMap)
		case "@include":
			value, err := p.parseValue(scope, true)
			if err != nil {
				return nil, err
			}

			file, ok := value.(string)
			if !ok {
				return nil, fmt.Errorf("@include must be a string, got %T", value)
			}
			content, err := parseFile(path.Join(p.cwd, file))
			if err != nil {
				return nil, fmt.Errorf("while reading %s: %w", file, err)
			}
			contentMap, ok := content.(map[string]any)
			if !ok {
				return nil, fmt.Errorf("unable to include %T", content)
			}
			maps.Copy(result, contentMap)

		default:
			value, err := p.parseValue(scope, dooutput)
			if err != nil {
				return nil, err
			}

			result[keyStr], err = p.interpolate(value, scope)
			if err != nil {
				return nil, err
			}
		}
	}

	// Consume the closing '}'
	if _, err := p.dec.Token(); err != nil {
		return nil, err
	}

	if dooutput {
		if _, ok := result["@output"]; ok {
			return p.output(result)
		}
	}

	if value, ok := result["@"]; ok {
		return value, nil
	}

	return result, nil
}

/* parseArray parses a JSON array into []any. */
func (p *Parser) parseArray(scope map[string]any, dooutput bool) ([]any, error) {
	var result []any
	for p.dec.More() {
		value, err := p.parseValue(scope, dooutput)
		if err != nil {
			return nil, err
		}
		resolvedValue, err := p.interpolate(value, scope)
		if err != nil {
			return nil, err
		}
		result = append(result, resolvedValue)
	}

	// Consume the closing ']'
	if _, err := p.dec.Token(); err != nil {
		return nil, err
	}

	return result, nil
}

/* parseFile reads and processes a JSON file, resolving includes and definitions. */
func parseFile(filename string) (any, error) {
	file, err := os.Open(filename)
	if err != nil {
		return nil, fmt.Errorf("failed to open file %s: %w", filename, err)
	}
	defer file.Close()

	cwd, _ := filepath.Abs(path.Dir(filename))
	parser := Parser{
		dec: json.NewDecoder(file),
		cwd: cwd,
	}

	return parser.parseValue(map[string]any{}, true)
}

func main() {
	os.MkdirAll("store", 0755)
	res, err := parseFile("../../data.json")
	if err != nil {
		panic(err)
	}
	switch res := res.(type) {
	case string:
		fmt.Println(res)
	case []any:
		for _, r := range res {
			fmt.Println(r)
		}
	}
}
