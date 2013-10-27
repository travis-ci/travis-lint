package lint

import (
	"testing"
)

func TestLintInvalidYAML(t *testing.T) {
	valid, errors := Lint([]byte("\tfoo: bar"))

	if valid {
		t.Errorf("Expected config with invalid YAML to be invalid")
	}
	if errors == nil {
		t.Errorf("Expected invalid YAML to return errors, got none")
	}
}
