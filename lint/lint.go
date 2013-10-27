package lint

import (
	"fmt"
	"launchpad.net/goyaml"
)

type Linter struct {
	Lint func(config map[string]interface{}, part interface{}) (valid bool, errors []error)
	Key string
}

var linters = []*Linter{
	languageLint,
}

type unknownKeyError struct {
	key string
}

func (e *unknownKeyError) Error() string {
	return fmt.Sprintf("Unknwon key: %s", e.key)
}

func Lint(configYaml []byte) (valid bool, errors []error) {
	var config map[string]interface{}
	err := goyaml.Unmarshal(configYaml, &config)
	if err != nil {
		return false, []error{err}
	}

	valid = true
	for key := range config {
		v, es := lintKey(key, config)
		if !v {
			valid = false
		} else {
			fmt.Printf("Valid key: %s\n", key)
		}
		errors = concatErrors(errors, es)
	}

	return
}

func lintKey(key string, config map[string]interface{}) (valid bool, errors []error) {
	for _, linter := range linters {
		if linter.Key == key {
			return linter.Lint(config, config[key])
		}
	}

	return false, []error{&unknownKeyError{key}}
}

func concatErrors(a, b []error) (errors []error) {
	for _, err := range a {
		errors = append(errors, err)
	}
	for _, err := range b {
		errors = append(errors, err)
	}

	return
}
