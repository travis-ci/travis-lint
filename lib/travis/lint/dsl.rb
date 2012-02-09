require "travis/lint/validator"

module Travis
  module Lint
    module DSL
      @@validators = []

      def validator_for(language, key, message, &validator)
        @@validators << Validator.new(language, key, message, validator)
      end


      def validators_for_language(language)
        @@validators.select { |v| v.language.to_s.downcase == language.to_s.downcase }
      end

      def generic_validators
        @@validators.select { |v| v.language.to_s.downcase == :all.to_s }
      end

      def find_validators_for(language)
        generic_validators + validators_for_language(language)
      end
    end
  end
end
