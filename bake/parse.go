package main

import (
	"encoding/json"
	"fmt"
	"maps"
	"os"
	"path"
	"path/filepath"
	"strings"
)

type Parser struct {
	dec *json.Decoder
	cwd string
}

type Object struct {
	parent   *Object
	defines  map[string]any
	includes []string
	extends  []string
	values   map[string]any
}

func (p *Parser) parseValue(parent *Object) (any, error) {
	token, err := p.dec.Token()
	if err != nil {
		return nil, err
	}

	switch tok := token.(type) {
	case json.Delim:
		switch tok {
		case '{':
			return p.parseMap(parent)
		case '[':
			return p.parseArray(parent)
		}
	case string:
		if strings.HasPrefix(tok, "./") {
			return path.Join(p.cwd, tok), nil
		}
		return tok, nil
	default:
		return tok, nil
	}
	return nil, fmt.Errorf("unexpected token: %v", token)
}

func (p *Parser) parseMap(parent *Object) (*Object, error) {
	result := &Object{
		parent:  parent,
		defines: make(map[string]any),
		values:  make(map[string]any),
	}

	for p.dec.More() {
		key, err := p.dec.Token()
		if err != nil {
			return nil, err
		}
		keyStr, ok := key.(string)
		if !ok {
			return nil, fmt.Errorf("expected string key, got %T", key)
		}
		value, err := p.parseValue(result)
		if err != nil {
			return nil, err
		}
		switch keyStr {
		case "@define":
			defs, ok := value.(*Object)
			if !ok {
				return nil, fmt.Errorf("@define must be a map, got %T", value)
			}
			maps.Copy(result.defines, defs.values)
		case "@expand":
			name, ok := value.(string)
			if !ok {
				return nil, fmt.Errorf("@expand variable must be string, got %T", value)
			}
			result.extends = append(result.extends, name)
		case "@include":
			file, ok := value.(string)
			if !ok {
				return nil, fmt.Errorf("@include must be a string, got %T", value)
			}
			result.includes = append(result.includes, file)
		default:
			result.values[keyStr] = value
		}
	}
	_, err := p.dec.Token() // Consume '}'
	return result, err
}

func (p *Parser) parseArray(parent *Object) ([]any, error) {
	var result []any
	for p.dec.More() {
		value, err := p.parseValue(parent)
		if err != nil {
			return nil, err
		}
		result = append(result, value)
	}
	_, err := p.dec.Token() // Consume ']'
	return result, err
}

func parseFile(filename string, parent *Object) (any, error) {
	file, err := os.Open(filename)
	if err != nil {
		return nil, fmt.Errorf("failed to open file %s: %w", filename, err)
	}
	defer file.Close()
	cwd, _ := filepath.Abs(path.Dir(filename))
	parser := Parser{dec: json.NewDecoder(file), cwd: cwd}
	return parser.parseValue(parent)
}
