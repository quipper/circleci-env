require "circleci/env/dsl"
require "circleci/env/vault"

module Circleci
  module Env
    module Command
      class ShellExport
        include Circleci::Env::Vault

        def initialize(config:, project_id:, password:)
          @config = config
          @project_id = project_id
          @password = password
        end

        def run
          secrets(@password) do |name, contents|
            Circleci::Env.app.add_secret(name, contents)
          end

          load(@config, true)

          project = DSL::Project::projects.find {|p| p.id == @project_id}
          raise "Project #{@project_id} not found" unless project

          project.envvars.each do |e|
            puts "export #{e.name}=#{e.value}"
          end
        end
      end
    end
  end
end
