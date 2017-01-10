require_relative "./env_var"

module Circleci
  module Env
    module DSL
      class Project
        @@projects = []

        attr_reader :env_vars

        def self.define(id)
          new(id)
        end

        def self.projects
          @@projects
        end

        def id
          "#{@vcs_type}/#{@username}/#{@repository}"
        end

        def env(key, value)
          env_var = EnvVar.new(key, value)
          @env_vars << env_var
        end

        def to_s
          "Project(id=#{id}, env_vars=#{env_vars.join(", ")})"
        end

        private

        def initialize(id)
          @env_vars = []
          parse_id(id)

          @@projects << self
        end

        def parse_id(id)
          @vcs_type, @username, @repository = id.split("/")
        end
      end
    end
  end
end
