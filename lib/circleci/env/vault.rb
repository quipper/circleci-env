require "ansible/vault"

module Circleci
  module Env
    module Vault
      SECRET_DIR = "secret"

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
          yield(name, contents)
        end
      end
    end
  end
end
