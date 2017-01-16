require "fileutils"
require_relative "../vault_command"

module Circleci
  module Env
    module Command
      module Vault
        class ListCommand < VaultCommand
          def initialize(password:)
            @password = password
          end

          def run
            puts "=== Secret Vars".light_blue
            max_len = 0
            vars = []
            Dir.glob("secret/*.vault") do |file|
              name = File.basename(file, ".vault")
              contents = Ansible::Vault.read(path: secret_file_path(name), password: @password)
              max_len = name.length if max_len < name.length
              vars << [name, contents]
            end

            max_len += 2
            vars.each do |v|
              puts "#{(v[0]+':').ljust(max_len, ' ').light_green}#{v[1]}"
            end
          end
        end
      end
    end
  end
end
