module Circleci
  module Env
    class App
      def initialize
        @secrets = {}
      end

      def secret(name)
        @secrets[name]
      end

      def add_secret(name, value)
        @secrets[name] = value
      end
    end
  end
end
