require "spec_helper"
require "stringio"

def capture_stdouterr
  $stdout = StringIO.new
  $stderr = StringIO.new
  yield
ensure
  $stdout = STDOUT
  $stderr = STDERR
end

class ExploitableClassBuilder
  def []=(key, value)
    Class.new.class_eval <<-EOS
      def #{key}
        #{value}
      end
    EOS
  end
end

describe "A .travis.yml" do
  context "with issues" do
    it "run should exit with non-zero exit status" do
      status = 0

      begin
        capture_stdouterr do
          Travis::Lint::Runner.new(["spec/files/uses_unsupported_perl.yml"]).run
        end
      rescue SystemExit => e
        status = e.status
      end

      status.should_not == 0
    end
  end

  context "with an exploit" do
    it "loads safely" do
      expect {
        capture_stdouterr {
          Travis::Lint::Runner.new(["spec/files/contains_exploit.yml"]).run
        }
      }.to_not raise_exception(RuntimeError, "I'm in yr system!")
    end
  end
end
