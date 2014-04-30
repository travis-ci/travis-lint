require "travis/lint/dsl"

require "hashr"

module Travis
  module Lint
    class Linter

      #
      # Behaviors
      #

      extend Lint::DSL


      #
      # API
      #

      def self.validate(hsh)
        hsh = Hashr.new hsh

        find_validators_for(hsh[:language]).inject([]) do |acc, val|
          acc << val.call(hsh)
          acc
        end.reject(&:first).map { |pair| pair[1] }
      end

      def self.valid?(hsh)
        validate(hsh).empty?
      end

      #
      # Erlang
      #

      validator_for :erlang, :otp_release, "Specify OTP releases you want to test against using the \"otp_release\" key" do |hsh|
        hsh[:language].to_s.downcase == "erlang" && blank?(hsh[:otp_release])
      end


      #
      # Ruby
      #

      validator_for :ruby, :rvm, "Specify Ruby versions/implementations you want to test against using the \"rvm\" key" do |hsh|
        hsh[:language].to_s.downcase == "ruby" && blank?(hsh[:rvm])
      end

      validator_for :ruby, :rvm, "Prefer jruby-18mode RVM alias to jruby" do |hsh|
        hsh[:rvm].is_a?(Array) && hsh[:rvm].include?("jruby")
      end

      validator_for :ruby, :rvm, "rbx-18mode RVM alias is no longer provide. Please use one of rbx, rbx-X, rbx-X.Y, or rbx-X.Y.Z depending on your desired version" do |hsh|
        hsh[:rvm].is_a?(Array) && hsh[:rvm].include?("rbx-18mode")
      end

      validator_for :ruby, :rvm, "rbx-19mode RVM alias is no longer provide. Please use one of rbx, rbx-X, rbx-X.Y, or rbx-X.Y.Z depending on your desired version" do |hsh|
        hsh[:rvm].is_a?(Array) && hsh[:rvm].include?("rbx-19mode")
      end

      validator_for :ruby, :rvm, "rbx-2.0.0pre RVM alias is no longer provided. Please use one of rbx, rbx-X, rbx-X.Y, or rbx-X.Y.Z depending on your desired version" do |hsh|
        hsh[:rvm].is_a?(Array) && hsh[:rvm].include?("rbx-2.0.0pre")
      end

      validator_for :ruby, :rvm, "Ruby 1.9.1 is no longer maintained and is no longer provided on travis-ci.org. Please move to 1.9.3." do |hsh|
        hsh[:rvm].is_a?(Array) && hsh[:rvm].include?("1.9.1")
      end

      validator_for :ruby, :rvm, "Ruby 1.8.6 is no longer maintained and is no longer provided on travis-ci.org. Please move to 1.8.7." do |hsh|
        hsh[:rvm].is_a?(Array) && hsh[:rvm].include?("1.8.6")
      end

      DOCS_URL = "Travis CI documentation at http://bit.ly/travis-ci-environment"

      validator_for :ruby, :rvm, "Detected unsupported Ruby versions. For an up-to-date list of supported Rubies, see #{DOCS_URL}" do |hsh|
        ("ruby" == hsh[:language].to_s.downcase) && hsh[:rvm].is_a?(Array) && !known_ruby_versions?(hsh[:rvm])
      end

      validator_for :ruby, :language, "Language is set to Ruby but node_js key is present. Ruby builder will ignore node_js key." do |hsh|
        hsh[:language].to_s.downcase == "ruby" && ! blank?(hsh[:node_js])
      end


      KNOWN_RUBY_VERSIONS = %w(1.8.7 ruby-1.8.7 1.9.2 ruby-1.9.2 1.9.3 ruby-1.9.3 2.0.0 ruby-2.0.0 2.1.0 ruby-2.1.0 2.1.1 ruby-2.1.1 ruby-head jruby jruby-18mode jruby-19mode rbx rbx-18mode rbx-19mode jruby-head ree ree-1.8.7 2.1.0-preview2 ruby-2.1.0-preview2 2.1.0-preview1 ruby-2.1.0-preview1 ree-1.8.7-2011.12)
      KNOWN_NODE_VERSIONS = %w(0.6 0.8 0.9 0.10 0.11)
      KNOWN_PHP_VERSIONS  = %w(5.2 5.3 5.3.3 5.4 5.5 5.6 hhvm)

      KNOWN_PYTHON_VERSIONS  = %w(2.6 2.7 3.2 3.3 3.4 pypy)
      KNOWN_PERL_VERSIONS    = %w(5.8 5.10 5.12 5.14 5.16 5.18 5.19)


      #
      # PHP
      #

      validator_for :php, :php, "Detected unsupported PHP versions. For an up-to-date list of supported PHP versions, see #{DOCS_URL}" do |hsh|
        ("php" == hsh[:language].to_s.downcase) && hsh[:php].is_a?(Array) && !known_php_versions?(hsh[:php])
      end

      #
      # Python
      #

      validator_for :python, :python, "Detected unsupported Python versions. For an up-to-date list of supported Python versions, see #{DOCS_URL}" do |hsh|
        ("python" == hsh[:language].to_s.downcase) && hsh[:python].is_a?(Array) && !known_python_versions?(hsh[:python])
      end

      #
      # Perl
      #

      validator_for :perl, :perl, "Detected unsupported Perl versions. For an up-to-date list of supported Perl versions, see #{DOCS_URL}" do |hsh|
        ("perl" == hsh[:language].to_s.downcase) && hsh[:perl].is_a?(Array) && !known_perl_versions?(hsh[:perl])
      end


      #
      # Node.js
      #

      validator_for :node_js, :node_js, "Detected unsupported Node.js versions. For an up-to-date list of supported Node.js versions, see #{DOCS_URL}" do |hsh|
        ("node_js" == hsh[:language].to_s.downcase) && hsh[:node_js].is_a?(Array) && !known_node_js_versions?(hsh[:node_js])
      end

      validator_for :all, :matrix, "Allowed matrix failures must contain a list of hashes." do |hash|
        if hash[:matrix] && hash[:matrix].is_a?(Hash) && hash[:matrix][:allow_failures]
          !hash[:matrix][:allow_failures].any?{|failure| failure.is_a?(Hash)}
        end
      end

      validator_for :all, :matrix, "Matrix includes must be a list of hashes." do |hash|
        if hash[:matrix] && hash[:matrix].is_a?(Hash) && hash[:matrix][:include]
          !hash[:matrix][:include].any?{|failure| failure.is_a?(Hash)}
        end
      end

      validator_for :all, :matrix, "Matrix must be a hash." do |hash|
        !(hash[:matrix].nil? || hash[:matrix].is_a?(Hash))
      end

      validator_for :all, :language, "Language must be valid" do |hash|
        hash.has_key?(:language) && validators_for_language(hash[:language]).empty?
      end

      protected

      def self.known_ruby_versions?(ary)
        ary = ary.map(&:to_s)

        unknown = ary - KNOWN_RUBY_VERSIONS
        unknown.empty?
      end

      def self.known_node_js_versions?(ary)
        ary = ary.map(&:to_s)

        unknown = ary - KNOWN_NODE_VERSIONS
        unknown.empty?
      end

      def self.known_php_versions?(ary)
        ary = ary.map(&:to_s)

        unknown = ary - KNOWN_PHP_VERSIONS
        unknown.empty?
      end

      def self.known_python_versions?(ary)
        ary = ary.map(&:to_s)

        unknown = ary - KNOWN_PYTHON_VERSIONS
        unknown.empty?
      end

      def self.known_perl_versions?(ary)
        ary = ary.map(&:to_s)

        unknown = ary - KNOWN_PERL_VERSIONS
        unknown.empty?
      end

    end
  end
end
