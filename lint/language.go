package lint

import (
	"errors"
	"fmt"
)

var languageLint = &Linter{
	Lint: lintLanguage,
	Key: "language",
}

var languages = []string{
	"c",
	"clojure",
	"c++", "cpp", "cplusplus",
	"erlang",
	"go",
	"groovy",
	"haskell",
	"java",
	"node_js",
	"objective-c",
	"perl",
	"php",
	"python",
	"ruby",
	"scala",
}

func lintLanguage(config map[string]interface{}, part interface{}) (valid bool, errs []error) {
	language, ok := part.(string)
	if !ok {
		return false, []error{errors.New("language must be a string")}
	}

	for _, allowedLanguage := range languages {
		if allowedLanguage == language {
			return true, nil
		}
	}
	return false, []error{errors.New(fmt.Sprintf("language not valid: %s", language))}
}
