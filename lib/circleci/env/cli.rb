require "commander"
require "circleci/env/command/apply_command"

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
          c.option "--dry-run", "Run dry-run mode"
          c.action do |args, options|
            options.default config: "Envfile", token: ENV['CIRCLECI_TOKEN']
            if options.token.nil?
              command(:help).run(['apply'])
              raise 'You need to set TOKEN'
            end

            command = Command::ApplyCommand.new(options)
            command.run
          end
        end

        never_trace!
        run!
      end
    end
  end
end
