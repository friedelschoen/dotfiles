package main

import (
	"encoding/json"
	"fmt"
	"io"
	"maps"
	"os"
	"path"
	"path/filepath"
	"strings"
)

type Parser struct {
	dec      *json.Decoder
	cwd      string
	filename string
}

type Object struct {
	parent   *Object
	filename string
	offset   int64
	defines  map[string]Object
	includes []Object
	extends  []Object
	value    any
}

func (o Object) position() string {
	if o.filename == "" {
		return "<unknown>"
	}
	file, err := os.Open(o.filename)
	if err != nil {
		return fmt.Sprintf("%s:1:%d", o.filename, o.offset)
	}
	defer file.Close()

	var (
		line       = 1
		lineOffset = int64(0)
		buf        = make([]byte, 4096)
		total      = int64(0)
	)

	for {
		n, err := file.Read(buf)
		if n == 0 && err != nil {
			break
		}
		for i := range n {
			if total == o.offset {
				return fmt.Sprintf("%s:%d:%d", path.Base(o.filename), line, int(o.offset-lineOffset))
			}
			if buf[i] == '\n' {
				line++
				lineOffset = total + 1
			}
			total++
		}
		if err == io.EOF {
			break
		}
		if err != nil {
			return "<unknown>"
		}
	}

	// If offset is beyond EOF, fallback to last known position
	return fmt.Sprintf("%s:%d:%d", path.Base(o.filename), line, int(o.offset-lineOffset))
}

func (o Object) MarshalJSON() ([]byte, error) {
	/* TODO: implement @include ... */
	return json.Marshal(o.value)
}

func (p *Parser) parseValue(parent *Object) (Object, error) {
	token, err := p.dec.Token()
	if err != nil {
		return Object{}, err
	}

	switch tok := token.(type) {
	case json.Delim:
		switch tok {
		case '{':
			return p.parseMap(parent)
		case '[':
			return p.parseArray(parent)
		default:
			return Object{}, nil
		}
	case string:
		if strings.HasPrefix(tok, "./") {
			tok = path.Join(p.cwd, tok)
		}
		return Object{
			parent:   parent,
			filename: p.filename,
			offset:   p.dec.InputOffset(),
			value:    tok,
		}, nil
	default:
		return Object{
			parent:   parent,
			filename: p.filename,
			offset:   p.dec.InputOffset(),
			value:    tok,
		}, nil
	}
}

func (p *Parser) parseMap(parent *Object) (Object, error) {
	values := make(map[string]Object)
	result := Object{
		parent:   parent,
		filename: p.filename,
		offset:   p.dec.InputOffset(),
		defines:  make(map[string]Object),
		value:    values,
	}

	for p.dec.More() {
		key, err := p.dec.Token()
		if err != nil {
			return Object{}, err
		}
		keyStr, ok := key.(string)
		if !ok {
			return Object{}, fmt.Errorf("%s: expected string-key, got %T", result.position(), key)
		}
		value, err := p.parseValue(&result)
		if err != nil {
			return Object{}, err
		}
		switch keyStr {
		case "@define":
			defs, ok := value.value.(map[string]Object)
			if !ok {
				return Object{}, fmt.Errorf("%s: @define must be a map, got %T", value.position(), value)
			}
			maps.Copy(result.defines, defs)
		case "@expand":
			_, ok := value.value.(string)
			if !ok {
				return Object{}, fmt.Errorf("%s: @expand variable must be string, got %T", value.position(), value)
			}
			result.extends = append(result.extends, value)
		case "@include":
			_, ok := value.value.(string)
			if !ok {
				return Object{}, fmt.Errorf("%s: @include must be a string, got %T", value.position(), value)
			}
			result.includes = append(result.includes, value)
		default:
			values[keyStr] = value
		}
	}
	_, err := p.dec.Token() // Consume '}'

	if attr, ok := values["@"]; ok {
		if len(values) != 1 {
			return Object{}, fmt.Errorf("%s: map with @ has more than 1 value", values["@"].position())
		}
		result.value = attr
	}

	return result, err
}

func (p *Parser) parseArray(parent *Object) (Object, error) {
	obj := Object{
		parent:   parent,
		filename: p.filename,
		offset:   p.dec.InputOffset(),
	}
	var result []Object
	for p.dec.More() {
		value, err := p.parseValue(parent)
		if err != nil {
			return Object{}, err
		}
		result = append(result, value)
	}
	_, err := p.dec.Token() // Consume ']'
	obj.value = result
	return obj, err
}

func parseFile(obj Object, filename string, parent *Object) (Object, error) {
	file, err := os.Open(filename)
	if err != nil {
		return Object{}, fmt.Errorf("%s: failed to open file %s: %w", obj.position(), filename, err)
	}
	defer file.Close()
	abs, _ := filepath.Abs(filename)
	parser := Parser{dec: json.NewDecoder(file), cwd: path.Dir(abs), filename: filename}
	return parser.parseValue(parent)
}
