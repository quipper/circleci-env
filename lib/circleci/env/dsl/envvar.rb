module Circleci
  module Env
    module DSL
      class Envvar
        attr_reader :name, :value

        def initialize(name, value)
          @name = name
          @value = value
        end

        def changed?(current_suffix)
          current_suffix.empty? || !value.end_with?(current_suffix)
        end

        def to_s
          "Envvar(#{name}=#{value})"
        end
      end
    end
  end
end
