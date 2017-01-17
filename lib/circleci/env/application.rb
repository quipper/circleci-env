require "singleton"

module Circleci
  module Env
    class Application
      include Singleton

      def secret(name)
        @secrets[name]
      end

      def add_secret(name, value)
        @secrets[name] = value
      end

      private

      def initialize
        @secrets = {}
      end
    end
  end
end
