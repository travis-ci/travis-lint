module Travis
  module Lint
    module DSL
      class Validator < Struct.new(:language, :key, :message, :validator)
        def call(hash)
          if self.validator.call(hash)
            [false, { :key => self.key, :issue => self.message }]
          else
            [true, {}]
          end
        end
      end
    end
  end
end
