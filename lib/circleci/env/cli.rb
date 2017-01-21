require "commander"
require "circleci/env/command/apply"
require "circleci/env/command/export"
require "circleci/env/command/vault/list"
require "circleci/env/command/vault/read"
require "circleci/env/command/vault/rekey"
require "circleci/env/command/vault/write"

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
          if options.password
            passwd = options.password
          elsif options.password_file
            passwd = File.read(options.password_file).chomp
          elsif ENV['CIRCLECI_ENV_PASSWORD']
            passwd = ENV['CIRCLECI_ENV_PASSWORD']
          else
            passwd = ask("Password: ") { |q| q.echo = "*" }
          end
        end

        command :apply do |c|
          c.syntax = "circleci-env apply [options]"
          c.description = "Apply CiecleCI environment variables from config files"
          c.option "-c", "--config FILE", String, "Config file name"
          c.option "--token TOKEN", String, "CircleCI API token"
          c.option "-p", "--password PASSWORD", String, "Specify password"
          c.option "--password-file PASSWORD_FILE", String, "Specify password file"
          c.option "--dry-run", "Run dry-run mode"
          c.action do |args, options|
            options.default config: "Envfile.rb", token: ENV['CIRCLECI_TOKEN'], password: fetch_password(options)
            if options.token.nil?
              command(:help).run(['apply'])
              raise 'You need to set TOKEN'
            end
            Command::Apply.new(options).run
          end
        end

        command :export do |c|
          c.syntax = "circleci-env export [options]"
          c.description = "Export CiecleCI environment variables from API"
          c.option "--filter REGEX", String, "Regex to filter projects"
          c.option "--ignore-empty", "Ignore project which has no environment variables"
          c.option "--token TOKEN", String, "CircleCI API token"
          c.action do |args, options|
            options.default token: ENV['CIRCLECI_TOKEN'], filter: ".*"
            if options.token.nil?
              command(:help).run(['export'])
              raise 'You need to set TOKEN'
            end
            Command::Export.new(options).run
          end
        end

        command :'vault write' do |c|
          c.syntax = "circleci-env vault write [options] <name> <value>"
          c.option "-p", "--password PASSWORD", String, "Specify password"
          c.option "--password-file PASSWORD_FILE", String, "Specify password file"
          c.description = "Write secret variable"
          c.action do |args, options|
            Command::Vault::Write.new(
              password: fetch_password(options),
              name: args.first,
              value: args.last
            ).run
          end
        end

        command :'vault read' do |c|
          c.syntax = "circleci-env vault read [options] <name>"
          c.option "-p", "--password PASSWORD", String, "Specify password"
          c.option "--password-file PASSWORD_FILE", String, "Specify password file"
          c.description = "Read secret variable"
          c.action do |args, options|
            Command::Vault::Read.new(
              password: fetch_password(options),
              name: args.first
            ).run
          end
        end

        command :'vault list' do |c|
          c.syntax = "circleci-env vault list [options]"
          c.option "-p", "--password-file PASSWORD_FILE", String, "Specify password file"
          c.description = "List all secret variables"
          c.action do |args, options|
            passwd = fetch_password(options)
            Command::Vault::List.new(
              password: passwd
            ).run
          end
        end

        command :'vault rekey' do |c|
          c.syntax = "circleci-env vault rekey"
          c.description = "Change password of all secret variables"
          c.action do |args, options|
            current_password = ask("Current Password: ") { |q| q.echo = "*" }
            new_password = ask("New Password: ") { |q| q.echo = "*" }
            Command::Vault::Rekey.new(
              current_password: current_password,
              new_password: new_password
            ).run
          end
        end

        run!
      end
    end
  end
end
