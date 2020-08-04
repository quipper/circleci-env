require "circleci/env"
require "circleci/env/api"
require "circleci/env/dsl"
require "circleci/env/vault"
require "circleci/env/command/apply/envvars"
require "circleci/env/command/apply/ssh_keys"
require "colorize"

module Circleci
  module Env
    module Command
      class Apply
        include Circleci::Env::Vault
        include Circleci::Env::Command::ApplyEnvvars
        include Circleci::Env::Command::ApplySSHKeys

        def initialize(config:, token:, password:, dry_run: false)
          @config = config
          @token = token
          @password = password
          @dry_run = dry_run
        end

        def run
          secrets(@password) do |name, contents|
            Circleci::Env.app.add_secret(name, contents)
          end

          load_config(@config)

          puts "Apply #{@config} to CircleCI#{dry_run? ? ' (dry-run)' : ''}"
          changed = false
          DSL::Project::projects.each do |proj|
            if !no_change?(proj) then
              changed = true
              apply(proj)
            end
          end
          if !changed then
            puts "no projects are changed"
          end
        end

        private

        def load_config(path)
          begin
            puts "Load config from #{path}"
            load(path, true)
          rescue Exception => e
            raise e
          end
        end

        def no_change?(project)
          envvars_no_change?(project) && ssh_keys_no_change?(project)
        end

        def apply(project)
          if !no_change?(project) then
            puts ""
            puts "=== #{project.id}"
            puts ""
            puts "Progress#{dry_run? ? '(dry-run)' : ''}: |"
            apply_envvars(project)
            apply_ssh_keys(project)
            show_result(project) unless dry_run?
          end
        end

        def show_result(project)
          puts ""
          puts "Result: |"
          show_envvars(project)
          show_ssh_keys(project)
        end

        def api
          @api ||= Api.new(@token)
        end

        def dry_run?
          @dry_run
        end

        def log_add(message)
          puts "  + add    #{message}".light_green
        end

        def log_delete(message)
          puts "  - delete #{message}".red
        end

        def log_update(message, changed=true)
          prefix = changed ?  "  ~" : "  ?"
          tmpl = "#{prefix} update #{message}"
          log = changed ? tmpl.yellow : tmpl.light_blue
          puts log
        end
      end
    end
  end
end
