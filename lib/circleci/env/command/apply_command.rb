require "circleci/env"
require "circleci/env/api"
require "circleci/env/dsl"
require "circleci/env/vault"
require "colorize"

module Circleci
  module Env
    module Command
      class ApplyCommand
        include Circleci::Env::Vault

        CIRCLECI_MASK_PREFIX = 'xxxx'

        def initialize(options)
          @options = options
        end

        def run
          secrets(@options.password) do |name, contents|
            Circleci::Env.app.add_secret(name, contents)
          end

          load_config(@options.config)

          puts "Apply #{@options.config} to CircleCI #{dry_run? ? '(dry-run)' : ''}"
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
          current_envvars = api.list_envvars(project.id).map{|e| [e['name'], e['value']]}.to_h
          defined_names = project.envvars.map(&:name)

          add_envvars = project.envvars.select{|e| !current_envvars.has_key?(e.name)}
          update_envvars = project.envvars.select{|e| current_envvars.has_key?(e.name)}
          delete_envvars = current_envvars.select{|k, v| !defined_names.include?(k)}

          puts ""
          puts "=== #{project.id}"
          puts ""
          puts "Progress#{dry_run? ? '(dry-run)' : ''}: |"

          add_envvars.each do |envvar|
            puts "  + add    #{envvar.name}=#{envvar.value.to_s}".light_green
            api.add_envvar(project.id, envvar.name, envvar.value.to_str) unless dry_run?
          end

          delete_envvars.each do |name, value|
            puts "  - delete #{name}".red
            api.delete_envvar(project.id, name) unless dry_run?
          end

          update_envvars.each do |envvar|
            tmpl = "  ~ update #{envvar.name}=#{envvar.value.to_s}"
            # CircleCI masked value prefix is 'xxxx', so remove it.
            current_suffix = current_envvars[envvar.name][CIRCLECI_MASK_PREFIX.length..-1]
            if envvar.value.end_with?(current_suffix)
              msg = "#{tmpl} (suffix matches current value)".light_blue
            else
              msg = tmpl.yellow
            end
            puts msg
            api.add_envvar(project.id, envvar.name, envvar.value.to_str) unless dry_run?
          end

          show_result(project) unless dry_run?
        end

        def show_result(project)
          puts ""
          puts "Result: |"

          api.list_envvars(project.id).each do |envvar|
            puts "  #{envvar['name']}=#{envvar['value']}"
          end
        end

        def api
          @api ||= Api.new(@options.token)
        end

        def dry_run?
          @options.dry_run
        end
      end
    end
  end
end
