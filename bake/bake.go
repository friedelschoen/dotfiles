package main

import (
	"fmt"
	"os"
)

func main() {
	os.MkdirAll("store", 0755)
	ast, err := parseFile("../data.json", nil)
	if err != nil {
		panic(err)
	}
	res, err := resolve(ast, map[string]any{})
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
