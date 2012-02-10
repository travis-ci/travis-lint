require "pathname"
require "yaml"

require "hashr"

require "travis/lint/linter"

module Travis
  module Lint

    class Runner
      def initialize(argv)
        if argv.empty?
          if File.exists?(".travis.yml")
            argv = [".travis.yml"]
          else
            show_help
          end
        end

        @travis_file_path = Pathname.new(argv.first).expand_path
      end


      def run
        check_that_travis_yml_file_exists!
        check_that_travis_yml_file_is_valid_yaml!

        if (issues = Linter.validate(self.parsed_travis_yml)).empty?
          puts "Hooray, .travis.yml at #{@travis_file_path} seems to be solid!"
        else
          issues.each do |i|
            puts "Found an issue with the `#{i[:key]}:` key:\n\n\t#{i[:issue]}"
            puts
            puts
          end
        end
      end


      protected

      def check_that_travis_yml_file_exists!
        quit("Cannot read #{@travis_file_path}: file does not exist or is not readable") unless File.exists?(@travis_file_path) &&
          File.file?(@travis_file_path) &&
          File.readable?(@travis_file_path)
      end

      def check_that_travis_yml_file_is_valid_yaml!
        begin
          YAML.load_file(@travis_file_path)
        rescue ArgumentError, Psych::SyntaxError => e
          quit ".travis.yml at #{@travis_file_path} is not a valid YAML file and thus will be ignored by Travis CI."
        end
      end

      def parsed_travis_yml
        Hashr.new(YAML.load_file(@travis_file_path))
      end

      def show_help
        puts <<-EOS
Usage:

    travis-lint [path to your .travis.yml]
      EOS

        exit(1)
      end

      def quit(message, status = 1)
        puts message
        puts

        exit(status)
      end
    end
  end
end
