require "ansible/vault"

module Circleci
  module Env
    module Vault
      class SecretString < String
        def to_s
          "xxxx#{self[-1]}"
        end

        def to_str
          self
        end
      end

      def secret_dir
        "secret"
      end

      def secret_file_path(name)
        "#{secret_dir}/#{name}.vault"
      end

      def read(name, password)
        Ansible::Vault.read(path: secret_file_path(name), password: password)
      end

      def write(name, value, password)
        Ansible::Vault.write(path: secret_file_path(name), plaintext: value, password: password)
      end

      def secrets(password)
        Dir.glob("#{secret_dir}/*.vault") do |file|
          name = File.basename(file, ".vault")
          contents = Ansible::Vault.read(path: file, password: password)
          yield(name, SecretString.new(contents))
        end
      end
    end
  end
end
