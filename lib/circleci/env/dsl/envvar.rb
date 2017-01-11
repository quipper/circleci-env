module Circleci
  module Env
    module DSL
      class Envvar
        attr_reader :name, :value

        def initialize(name, value)
          @name = name
          @value = value
        end

        def to_s
          "Envvar(#{name}=#{value})"
        end
      end
    end
  end
end
