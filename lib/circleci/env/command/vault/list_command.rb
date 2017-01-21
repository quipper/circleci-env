require "circleci/env/vault"

module Circleci
  module Env
    module Command
      module Vault
        class ListCommand
          include Circleci::Env::Vault

          def initialize(password:)
            @password = password
          end

          def run
            puts "=== Secret Variables".light_blue
            max_len = 0
            vars = []

            secrets(@password) do |name, contents|
              max_len = name.length if max_len < name.length
              vars << [name, contents]
            end

            max_len += 2
            vars.each do |v|
              puts "#{(v[0]+':').ljust(max_len, ' ').light_green}#{v[1].to_str}"
            end
          end
        end
      end
    end
  end
end
