require "spec_helper"
require "stringio"

def capture_stdout
  $stdout = StringIO.new
  yield
ensure
  $stdout = STDOUT
end

describe "A .travis.yml" do
  context "with issues" do
    it "run should exit with non-zero exit status" do
      status = 0

      begin
        capture_stdout do
          Travis::Lint::Runner.new(["spec/files/no_language_key.yml"]).run()
        end
      rescue SystemExit => e
        status = e.status
      end

      status.should_not == 0
    end
  end
end
