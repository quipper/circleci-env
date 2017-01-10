require "spec_helper"

describe Circleci::Env::Vault do
  shared_examples "vault" do |algorithm|
    let(:original_data) { "Something secret data." }
    let(:password) { "Passwor0d" }
    let(:encrypt_options) {
      opts = { value: original_data, password: password }
      opts[:algorithm] = algorithm if algorithm
      opts
    }

    it "decrypt encrypted data should return original data" do
      encrypted_data = Circleci::Env::Vault.encrypt(encrypt_options)
      expect(encrypted_data).not_to eq(original_data)

      decrypted_data = Circleci::Env::Vault.decrypt(value: encrypted_data, password: password)
      expect(decrypted_data).to eq(original_data)
    end

    it "encrypt should return different value with same value and password" do
      encrypted_data1 = Circleci::Env::Vault.encrypt(encrypt_options)
      encrypted_data2 = Circleci::Env::Vault.encrypt(encrypt_options)
      expect(encrypted_data1).not_to eq(encrypted_data2)
    end
  end

  describe "vault by default algorithm (aes-256-gcm)" do
    it_behaves_like "vault"
  end

  describe "vault by aes-256-cbc" do
    it_behaves_like "vault", "aes-256-cbc"
  end

  describe "unhexlify hexlify value" do
    it "should return original value" do
      original = OpenSSL::Random.random_bytes(16)
      hex = Circleci::Env::Vault.hexlify(original)
      expect(Circleci::Env::Vault.unhexlify(hex)).to eq(original)
    end
  end
end
