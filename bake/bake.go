package main

import (
	"fmt"
	"os"
)

func writeDot(filename string, edges []Edge) {
	dot, err := os.Create(filename)
	if err != nil {
		panic(err)
	}
	defer dot.Close()

	fmt.Fprintf(dot, "digraph D {\n")
	for _, e := range edges {
		fmt.Fprintf(dot, "\"%s\" -> \"%s\";\n", e[0], e[1])
	}
	fmt.Fprintf(dot, "}")
}

func main() {
	ast, err := parseFile("../data.json", nil)
	if err != nil {
		panic(err)
	}
	ev := Evaluator{
		Force:    false,
		DryRun:   false,
		CacheDir: "store",
	}

	os.MkdirAll(ev.CacheDir, 0755)
	os.MkdirAll(ev.LogDir, 0755)

	res, err := ev.resolve(ast, map[string]any{})
	if err != nil {
		panic(err)
	}

	writeDot("out.dot", ev.Edges)

	switch res := res.(type) {
	case string:
		fmt.Println(res)
	case []any:
		for _, r := range res {
			fmt.Println(r)
		}
	}
}
