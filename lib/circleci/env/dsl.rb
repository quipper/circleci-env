require "circleci/env/dsl/project"

module Circleci
  module Env
    module DSL
      class DSLError < StandardError; end

      def project(id, &block)
        proj = Project.define(id)
        proj.instance_eval(&block)
      end
    end
  end
end

# Extend the main object with the DSL commands.
# This allows top-level calls to dsl methods, etc.
extend Circleci::Env::DSL
