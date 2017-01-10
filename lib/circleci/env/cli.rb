require "commander"
require 'colorize'
require "circleci/env/dsl"

module Circleci
  module Env
    class CLI
      include Commander::Methods

      def run
        program :name, "circleci-env"
        program :version, Circleci::Env::VERSION
        program :description, "circleci-env is a tool to manage CircleCI environment variables."
        program :help_formatter, :compact

        command :apply do |c|
          c.syntax = "circleci-env apply [options]"
          c.description = "Apply CiecleCI environment variables from config files"
          c.option "-c", "--config FILE", String, "Config file name"
          c.option "-t", "--token TOKEN", String, "CircleCI API token"
          c.action do |args, options|
            if options.token.nil?
              command(:help).run(['apply'])
              raise 'You need to set TOKEN'
            end

            options.default config: "Envfile.rb"
            load_config(options.config)

            api = Api.new(options.token)

            DSL::Project::projects.each do |proj|
              puts ""
              puts "=== #{proj.id}"
              puts ""
              puts "Progress: |"
              proj.env_vars.each do |env_var|
                puts "  + add #{env_var.name}".light_green
                api.add_envvar(proj.id, env_var.name, env_var.value)
              end
              puts ""
              puts "Result: |"

              api.list_envvars(proj.id).each do |env_var|
                puts "  #{env_var['name']} = #{env_var['value']}".light_blue
              end
            end
          end
        end

        never_trace!
        run!
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
    end
  end
end
