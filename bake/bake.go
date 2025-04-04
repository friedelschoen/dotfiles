package main

import (
	"flag"
	"fmt"
	"os"
	"strings"
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
	ev := Evaluator{}
	resultName := "result"
	noResult := false
	dotName := ""

	flag.BoolVar(&ev.Force, "force", false, "force building all outputs")
	flag.BoolVar(&ev.Force, "dry", false, "do not build anything")
	flag.StringVar(&ev.CacheDir, "cache", "cache", "`destination` of outputs")
	flag.StringVar(&ev.LogDir, "log", "cache/log", "`destination` of logs of outputs")
	flag.StringVar(&resultName, "result", "result", "`name` of result-symlink")
	flag.BoolVar(&noResult, "no-result", false, "disables creation of result-symlink")
	flag.StringVar(&dotName, "graph", "", "`destination` of dependency graph (DOT formatted)")
	flag.BoolVar(&ev.Serial, "serial", false, "do not build output asynchronous")
	flag.StringVar(&ev.Interpreter, "interpreter", "sh", "default interpreter for @output")
	flag.Parse()

	if ev.DryRun && ev.Force {
		ev.Force = false
	}

	filename := ""
	scope := make(map[string]any)
	for _, arg := range flag.Args() {
		if name, value, ok := strings.Cut(arg, "="); ok {
			scope[name] = value
		} else if filename == "" {
			filename = arg
		} else {
			fmt.Fprintf(os.Stderr, "obsolete argument: `%s`\n", arg)
			os.Exit(1)
		}
	}

	if filename == "" {
		fmt.Fprintf(os.Stderr, "no file provided\n")
		os.Exit(1)
	}

	ast, err := parseFile(filename, nil)
	if err != nil {
		panic(err)
	}

	os.MkdirAll(ev.CacheDir, 0755)
	os.MkdirAll(ev.LogDir, 0755)

	res, err := ev.resolve(ast, scope)
	if err != nil {
		panic(err)
	}

	if dotName != "" {
		writeDot(dotName, ev.Edges)
	}

	switch res := res.(type) {
	case string:
		fmt.Printf("%s\n", res)
		if !noResult {
			os.Symlink(res, resultName)
		}
	case []any:
		for i, r := range res {
			rs, ok := r.(string)
			if !ok {
				fmt.Printf("expected string[]\n")
				os.Exit(1)
			}
			filename := fmt.Sprintf("%s-%d", resultName, i)
			fmt.Printf("%s\n", res)
			if !noResult {
				os.Symlink(rs, filename)
			}
		}
	}
}
