require "commander"
require "circleci/env/command/apply_command"
require "circleci/env/command/vault/write_command"
require "circleci/env/command/vault/read_command"

module Circleci
  module Env
    class CLI
      include Commander::Methods

      def run
        program :name, "circleci-env"
        program :version, Circleci::Env::VERSION
        program :description, "circleci-env is a tool to manage CircleCI environment variables."
        program :help_formatter, :compact

        def fetch_password(options)
          if options.password_file
            passwd = File.read(options.password_file).chomp
          else
            passwd = ask("Password: ") { |q| q.echo = "*" }
          end
        end

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
            Command::ApplyCommand.new(options).run
          end
        end

        command :'vault write' do |c|
          c.syntax = "circleci-env vault write name=value"
          c.option "-p", "--password-file PASSWORD_FILE", String, "Specify password file"
          c.description = "Write secret value"
          c.action do |args, options|
            Command::Vault::WriteCommand.new(
              password: fetch_password(options),
              name: args.first,
              value: args.last
            ).run
          end
        end

        command :'vault read' do |c|
          c.syntax = "circleci-env vault read name"
          c.option "-p", "--password-file PASSWORD_FILE", String, "Specify password file"
          c.description = "Read secret value"
          c.action do |args, options|
            Command::Vault::ReadCommand.new(
              password: fetch_password(options),
              name: args.first
            ).run
          end
        end

        never_trace!
        run!
      end
    end
  end
end
