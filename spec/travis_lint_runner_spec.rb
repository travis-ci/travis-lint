require "spec_helper"
require "stringio"

def capture
  status = nil
  $stdout = out = StringIO.new
  $stderr = err = StringIO.new

  begin
    yield
  rescue SystemExit => e
    status = e.status
  ensure
    $stdout = STDOUT
    $stderr = STDERR
  end

  err.rewind
  out.rewind
  return out.read || '', err.read || '', status
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
      _, _, status = capture do
        Travis::Lint::Runner.new(["spec/files/uses_unsupported_perl.yml"]).run
      end

      status.should_not == 0
    end

    it "run should report errors to $stderr" do
      _, err, _ = capture do
        Travis::Lint::Runner.new(["spec/files/uses_unsupported_perl.yml"]).run
      end

      err.chomp.should =~ /Found an issue with the `perl:` key:/
    end

    it "run should not report errors to $stdout" do
      out, _, _ = capture do
        Travis::Lint::Runner.new(["spec/files/uses_unsupported_perl.yml"]).run
      end

      out.chomp.should == ''
    end
  end

  context "without issues" do
    it "run should exit with zero exit status" do
      _, _, status = capture do
        Travis::Lint::Runner.new([".travis.yml"]).run
      end

      status.should == 0
    end

    it "run should report success to $stdout" do
      out, _, _ = capture do
        Travis::Lint::Runner.new([".travis.yml"]).run
      end

      out.chomp.should =~ /Hooray.*\.travis\.yml seems to be solid!/
    end

    context "with $QUIET set" do
      before { ENV['QUIET'] = '1' }
      after { ENV['QUIET'] = nil }

      it "run should be silent" do
        out, _, _ = capture do
          Travis::Lint::Runner.new([".travis.yml"]).run
        end

        out.chomp.should == ''
      end
    end
  end

  context "with an exploit" do
    it "loads safely" do
      expect {
        capture {
          Travis::Lint::Runner.new(["spec/files/contains_exploit.yml"]).run
        }
      }.to_not raise_error
    end
  end
end
