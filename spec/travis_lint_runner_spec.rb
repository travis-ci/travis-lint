require "spec_helper"

describe "A .travis.yml" do
  context "with issues" do
    it "run should exit with non-zero exit status" do
      status = 0

      begin
        Travis::Lint::Runner.new(["spec/files/no_language_key.yml"]).run()
      rescue SystemExit => e
        status = e.status
      end

      status.should_not == 0
    end
  end
end
