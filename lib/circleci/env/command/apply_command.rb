require "colorize"
require "circleci/env/api"
require "circleci/env/dsl"

module Circleci
  module Env
    module Command
      class ApplyCommand
        def initialize(options)
          @options = options
        end

        def run
          load_config(@options.config)

          puts "Apply #{@options.config} to CircleCI #{dry_run? ? '(dry-run)' : ''}"
          DSL::Project::projects.each do |proj|
            current_envvars = api.list_envvars(proj.id)
            current_names = current_envvars.map{|e| e['name']}
            defined_names = proj.envvars.map(&:name)

            add_envvars = proj.envvars.select{|e| !current_names.include?(e.name)}
            update_envvars = proj.envvars.select{|e| current_names.include?(e.name)}
            delete_envvars = current_envvars.select{|e| !defined_names.include?(e['name'])}

            puts ""
            puts "=== #{proj.id}"
            puts ""
            puts "Progress#{dry_run? ? '(dry-run)' : ''}: |"

            add_envvars.each do |envvar|
              puts "  + add    #{envvar.name} = #{envvar.value}".light_green
              api.add_envvar(proj.id, envvar.name, envvar.value) unless dry_run?
            end

            delete_envvars.each do |envvar|
              puts "  - delete #{envvar['name']} = #{envvar['value']}".red
              api.delete_envvar(proj.id, envvar['name']) unless dry_run?
            end

            update_envvars.each do |envvar|
              puts "  ~ update #{envvar.name} = #{envvar.value}".light_blue
              api.add_envvar(proj.id, envvar.name, envvar.value) unless dry_run?
            end

            unless dry_run?
              puts ""
              puts "Result: |"

              api.list_envvars(proj.id).each do |envvar|
                puts "  #{envvar['name']} = #{envvar['value']}"
              end
            end
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
