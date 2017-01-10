module Circleci
  module Env
    module DSL
      class EnvVar
        attr_reader :name, :value

        def initialize(name, value)
          @name = name
          @value = value
        end

        def to_s
          "EnvVar(#{name}=#{value})"
        end
      end
    end
  end
end
