require 'ansible/vault'
require "colorize"

module Circleci
  module Env
    module Command
      module Vault
        class VaultCommand
          SECRET_DIR = "secret"

          def secret_file_path(name)
            "#{SECRET_DIR}/#{name}.vault"
          end
        end
      end
    end
  end
end
