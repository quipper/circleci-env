require "ansible/vault"

class String
  def raw; self end
end

module Circleci
  module Env
    module Vault
      SECRET_DIR = "secret"

      class SecretString
        def initialize(str)
          @str = str
        end

        def raw
          @str
        end

        def to_s
          "xxxx#{@str[-1]}"
        end
      end

      def secret_file_path(name)
        "#{SECRET_DIR}/#{name}.vault"
      end

      def read(name, password)
        Ansible::Vault.read(path: secret_file_path(name), password: password)
      end

      def write(name, value, password)
        Ansible::Vault.write(path: secret_file_path(name), plaintext: value, password: password)
      end

      def secrets(password)
        Dir.glob("secret/*.vault") do |file|
          name = File.basename(file, ".vault")
          contents = Ansible::Vault.read(path: secret_file_path(name), password: password)
          yield(name, SecretString.new(contents))
        end
      end
    end
  end
end
