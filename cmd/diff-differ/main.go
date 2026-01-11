package main

import (
	"log"
	"os"

	"github.com/bluekeyes/go-gitdiff/gitdiff"
	"github.com/goforj/godump"
)

func main() {
	if len(os.Args) != 2 {
		log.Fatalf("usage: %s <file>\n", os.Args[0])
	}

	file, err := os.Open(os.Args[1])
	if err != nil {
		log.Fatal(err)
	}

	files, _, err := gitdiff.Parse(file)
	if err != nil {
		log.Fatal(err)
	}

	dumper := godump.NewDumper(godump.WithDisableStringer(true))

	//diffsMap := make(map[string]*diff.FileDiff)
	//distances := make(map[string]int)

	for _, f := range files {
		dumper.Dump(f)

		//if i == 0 {
		//	distances[d.OrigName] = 0
		//	diffsMap[d.OrigName] = d
		//} else {
		//
		//}
	}
}
