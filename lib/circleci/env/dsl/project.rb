require_relative "./envvar"
require "circleci/env/application"

module Circleci
  module Env
    module DSL
      class Project
        @@projects = []

        attr_reader :envvars

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
          @envvars << Envvar.new(key, value)
        end

        def secret(name)
          Circleci::Env::Application.instance.secret(name)
        end

        def to_s
          "Project(id=#{id}, env_vars=#{envvars.join(", ")})"
        end

        private

        def initialize(id)
          @envvars = []
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
