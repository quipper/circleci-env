require "fileutils"
require_relative "../vault_command"

module Circleci
  module Env
    module Command
      module Vault
        class WriteCommand < VaultCommand
          def initialize(name:, value:, password:)
            @name = name
            @value = value
            @password = password
          end

          def run
            FileUtils.mkdir_p(SECRET_DIR)

            puts "Write secret value to #{secret_file_path(@name)}"
            Ansible::Vault.write({
              path: secret_file_path(@name),
              password: @password,
              plaintext: @value
            })
          end
        end
      end
    end
  end
end
