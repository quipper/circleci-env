require "circleci/env/vault"
require "fileutils"

module Circleci
  module Env
    module Command
      module Vault
        class Write
          include Circleci::Env::Vault

          def initialize(name:, value:, password:)
            @name = name
            @value = value
            @password = password
          end

          def run
            FileUtils.mkdir_p(File.dirname(secret_file_path(@name)))
            puts "Write secret variable to #{secret_file_path(@name)}"
            write(@name, @value, @password)
          end
        end
      end
    end
  end
end
