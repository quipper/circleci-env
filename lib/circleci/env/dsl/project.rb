require "circleci/env"
require "circleci/env/dsl/envvar"
require "circleci/env/dsl/ssh_key"

module Circleci
  module Env
    module DSL
      class Project
        @@projects = []

        attr_reader :vcs_type, :username, :repository, :envvars, :ssh_keys

        def self.define(id)
          new(id)
        end

        def self.projects
          @@projects
        end

        def self.projects=(projects)
          @@projects = projects
        end

        def id
          "#{vcs_type}/#{username}/#{repository}"
        end

        def env(key_values)
          key_values.each do |key, value|
            raise DSLError.new("nil is not allowed for #{key} in #{id}") if value.nil?
            envvars << Envvar.new(key, value)
          end
        end

        def ssh_key(key_values)
          key_values.each do |key, value|
            raise DSLError.new("nil is not allowed for #{key} in #{id}") if value.nil?
            ssh_keys << SSHKey.new(key, value)
          end
        end

        def secret(name)
          Circleci::Env.app.secret(name)
        end

        def to_s
          s = "Project(id=#{id}"
          s += ", envvars=[#{envvars.join(", ")})]" if envvars.length > 0
          s += ", ssh_keys=[#{ssh_keys.join(", ")})]" if ssh_keys.length > 0
          s += ")"
        end

        private

        def initialize(id)
          @envvars = []
          @ssh_keys = []
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
