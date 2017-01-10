require "circleci/env/dsl/project"
require "circleci/env/dsl/env_var"

module Circleci
  module Env
    module DSL
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
