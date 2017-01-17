require "fileutils"
require "circleci/env/vault"

module Circleci
  module Env
    module Command
      module Vault
        class ReadCommand
          include Circleci::Env::Vault

          def initialize(name:, password:)
            @name = name
            @password = password
          end

          def run
            puts "Read secret value from #{secret_file_path(@name)}"
            puts read(@name, @password)
          end
        end
      end
    end
  end
end
