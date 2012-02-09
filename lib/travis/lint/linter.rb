require "active_support/core_ext/object/blank"
require "travis/lint/dsl"

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
        issues = find_validators_for(hsh[:language]).inject([]) do |acc, val|
          acc << val.call(hsh)
          acc
        end.reject(&:first).map { |pair| pair[1] }
      end

      def self.valid?(hsh)
        validate(hsh).empty?
      end


      #
      # General
      #

      validator_for :all, :language, "Language: key is mandatory" do |hsh|
        hsh[:language].blank?
      end


      #
      # Erlang
      #

      validator_for :erlang, :otp_release, "Specify OTP releases you want to test against using the :otp_release key" do |hsh|
        hsh[:language].to_s.downcase == "erlang" && hsh[:otp_release].blank?
      end


      #
      # Ruby
      #

      validator_for :ruby, :rvm, "Specify Ruby versions/implementations you want to test against using the :rvm key" do |hsh|
        hsh[:language].to_s.downcase == "ruby" && hsh[:rvm].blank?
      end

      validator_for :ruby, :rvm, "Prefer jruby-18mode RVM alias to jruby" do |hsh|
        hsh[:rvm].is_a?(Array) && hsh[:rvm].include?("jruby")
      end

      validator_for :ruby, :rvm, "Prefer rbx-18mode RVM alias to rbx" do |hsh|
        hsh[:rvm].is_a?(Array) && hsh[:rvm].include?("rbx")
      end

      validator_for :ruby, :rvm, "rbx-2.0 RVM alias is no longer provided. Please use rbx-18mode or rbx-19mode instead." do |hsh|
        hsh[:rvm].is_a?(Array) && hsh[:rvm].include?("rbx-2.0")
      end

      validator_for :ruby, :rvm, "rbx-2.0.0pre RVM alias is no longer provided. Please use rbx-18mode or rbx-19mode instead." do |hsh|
        hsh[:rvm].is_a?(Array) && hsh[:rvm].include?("rbx-2.0.0pre")
      end

      validator_for :ruby, :rvm, "Ruby 1.9.1 is no longer maintained and is no longer provided on travis-ci.org. Please move to 1.9.3." do |hsh|
        hsh[:rvm].is_a?(Array) && hsh[:rvm].include?("1.9.1")
      end

      validator_for :ruby, :rvm, "Ruby 1.8.6 is no longer maintained and is no longer provided on travis-ci.org. Please move to 1.8.7." do |hsh|
        hsh[:rvm].is_a?(Array) && hsh[:rvm].include?("1.8.6")
      end



      validator_for :ruby, :language, "Language is set to Ruby but node_js key is present. Ruby builder will ignore node_js key." do |hsh|
        hsh[:language].to_s.downcase == "ruby" && hsh[:node_js].present?
      end
    end
  end
end
