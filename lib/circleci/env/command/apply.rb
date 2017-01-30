require "circleci/env"
require "circleci/env/api"
require "circleci/env/dsl"
require "circleci/env/vault"
require "colorize"

module Circleci
  module Env
    module Command
      class Apply
        include Circleci::Env::Vault

        CIRCLECI_MASK_PREFIX = 'xxxx'

        def initialize(config:, token:, password:, dry_run: false)
          @config = config
          @token = token
          @password = password
          @dry_run = dry_run
          @current_envvars = {}
        end

        def run
          secrets(@password) do |name, contents|
            Circleci::Env.app.add_secret(name, contents)
          end

          load_config(@config)

          puts "Apply #{@config} to CircleCI#{dry_run? ? ' (dry-run)' : ''}"
          DSL::Project::projects.each do |proj|
            apply(proj)
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

        def apply(project)
          puts ""
          puts "=== #{project.id}"
          puts ""
          puts "Progress#{dry_run? ? '(dry-run)' : ''}: |"
          apply_envvars(project)
          show_result(project) unless dry_run?
        end

        def apply_envvars(project)
          add_envvars(project)
          delete_envvars(project)
          update_envvars(project)
        end

        def show_result(project)
          puts ""
          puts "Result: |"

          api.list_envvars(project.id).each do |envvar|
            puts "  #{envvar['name']}=#{envvar['value']}"
          end
        end

        def api
          @api ||= Api.new(@token)
        end

        def dry_run?
          @dry_run
        end

        def current_envvars(project)
          @current_envvars[project.id] ||= api.list_envvars(project.id).map{|e| [e['name'], e['value']]}.to_h
        end

        def added_envvars(project)
          current_names = current_envvars(project).keys
          project.envvars.select{|e| !current_names.include?(e.name)}
        end

        def updated_envvars(project)
          current_names = current_envvars(project).keys
          project.envvars.select{|e| current_names.include?(e.name)}
        end

        def deleted_envvars(project)
          defined_names = project.envvars.map(&:name)
          current_envvars(project).select{|k, v| !defined_names.include?(k)}
        end

        def add_envvars(project)
          added_envvars(project).each do |envvar|
            puts "  + add    #{envvar.name}=#{envvar.value.to_s}".light_green
            api.add_envvar(project.id, envvar.name, envvar.value.to_str) unless dry_run?
          end
        end

        def delete_envvars(project)
          deleted_envvars(project).each do |name, value|
            puts "  - delete #{name}".red
            api.delete_envvar(project.id, name) unless dry_run?
          end
        end

        def update_envvars(project)
          updated_envvars(project).each do |envvar|
            prefix = "  ~"
            msg_tmpl = "update #{envvar.name}=#{envvar.value.to_s}"
            # CircleCI masked value prefix is 'xxxx', so remove it.
            current_suffix = current_envvars(project)[envvar.name][CIRCLECI_MASK_PREFIX.length..-1]
            if envvar.changed?(current_suffix)
              msg = "#{prefix} #{msg_tmpl}".yellow
            else
              prefix = "  ?"
              msg = "#{prefix} #{msg_tmpl}".light_blue
            end
            puts msg
            api.add_envvar(project.id, envvar.name, envvar.value.to_str) unless dry_run?
          end
        end
      end
    end
  end
end
