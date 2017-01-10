require "openssl"

module Circleci
  module Env
    module Vault
      extend self

      def encrypt(value:, password:, algorithm: 'aes-256-gcm', auth_data: 'circleci-env')
        salt = OpenSSL::Random.random_bytes(16)

        cipher = OpenSSL::Cipher.new(algorithm)
        cipher.encrypt
        key1, key2, iv = generate_key(password, salt, cipher)
        cipher.key = key1
        cipher.iv = iv

        if cipher.authenticated?
          cipher.auth_data = auth_data
        end

        encrypted_data = ""
        encrypted_data << cipher.update(value)
        encrypted_data << cipher.final
        encrypted_data << cipher.auth_tag if cipher.authenticated?

        hmac = OpenSSL::HMAC.hexdigest('sha256', key2, encrypted_data)
        message = [algorithm, hexlify(salt), hmac, hexlify(encrypted_data)].join("\n")
        hexlify(message)
      end

      def decrypt(value:, password:, auth_data: 'circleci-env')
        algorithm, salt, hmac, encrypted_data = unhexlify(value).split("\n")
        salt = unhexlify(salt)
        encrypted_data = unhexlify(encrypted_data)

        cipher = OpenSSL::Cipher.new(algorithm)
        cipher.decrypt
        key1, key2, iv = generate_key(password, salt, cipher)
        cipher.key = key1
        cipher.iv = iv

        if not hmac == OpenSSL::HMAC.hexdigest('sha256', key2, encrypted_data)
          raise "Invalid value: #{value}"
        end

        if cipher.authenticated?
          cipher.auth_tag = extract_auth_tag(encrypted_data)
          cipher.auth_data = auth_data
          encrypted_data = extract_cipher_text(encrypted_data)
        end

        decrypted_data = ""
        decrypted_data << cipher.update(encrypted_data)
        decrypted_data << cipher.final
        decrypted_data
      end

      def hexlify(s)
        s.unpack('H*').first
      end

      def unhexlify(s)
        s.scan(/../).map(&:hex).pack('c*')
      end

      protected

      def generate_key(password, salt, cipher)
        key_len = cipher.key_len
        iv_len = cipher.iv_len
        iter = 20000
        digest = OpenSSL::Digest::SHA256.new
        len = key_len * 2 + iv_len
        key_iv = OpenSSL::PKCS5.pbkdf2_hmac(password, salt, iter, len, digest)
        [key_iv[0, key_len], key_iv[key_len, key_len], key_iv[key_len*2, iv_len]]
      end

      def extract_cipher_text(value)
        value[0..-17]
      end

      def extract_auth_tag(value)
        value[-16..-1]
      end
    end
  end
end
