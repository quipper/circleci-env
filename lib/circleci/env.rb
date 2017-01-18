require "circleci/env/app"
require "circleci/env/version"

module Circleci
  module Env
    class << self
      def app
        @app ||= App.new
      end
    end
  end
end
