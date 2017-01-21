require "circleci/env/vault"

module Circleci
  module Env
    module Command
      module Vault
        class Read
          include Circleci::Env::Vault

          def initialize(name:, password:)
            @name = name
            @password = password
          end

          def run
            puts "Read secret variable from #{secret_file_path(@name)}"
            puts read(@name, @password)
          end
        end
      end
    end
  end
end
