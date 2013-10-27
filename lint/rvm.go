package lint

import (
	"errors"
)

var rvmLint = &Linter{
	Lint: lintRvm,
	Key: "rvm",
}

func lintRvm(config map[string]interface{}, part interface{}) (valid bool, errs []error) {
	language, ok := config["language"].(string)
	if ok && language != "ruby" && language != "objective-c"  {
		return false, []error{errors.New("rvm key can only be used with ruby or objective-c")}
	}

	switch part.(type) {
	case string, []string:
		return true, nil
	default:
		return false, []error{errors.New("rvm must be a string or list")}
	}
}
