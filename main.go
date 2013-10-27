package main

import (
	"github.com/travis-ci/travis-lint/lint"
	"os"
	"io/ioutil"
	"fmt"
)

func main() {
	config, _ := ioutil.ReadAll(os.Stdin)

	valid, errors := lint.Lint(config)

	if valid {
		fmt.Println("Valid!")
	} else {
		fmt.Println("Invalid!")
		for _, err := range errors {
			fmt.Println(err)
		}
	}
}
