require "fileutils"
require_relative "../vault_command"

module Circleci
  module Env
    module Command
      module Vault
        class ReadCommand < VaultCommand
          def initialize(name:, password:)
            @name = name
            @password = password
          end

          def run
            puts "Read secret value from #{secret_file_path(@name)}"
            contents = Ansible::Vault.read(path: secret_file_path(@name), password: @password)
            puts contents
          end
        end
      end
    end
  end
end
