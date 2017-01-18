require "spec_helper"
require "circleci/env/vault"

describe Circleci::Env::Vault do
  describe Circleci::Env::Vault::SecretString do
    before do
      @str = Circleci::Env::Vault::SecretString.new("this is secret")
    end

    describe "#to_s" do
      it "should return masked value" do
        expect(@str.to_s).to eq "xxxxt"
      end
    end

    describe "#to_str" do
      it "should return raw value" do
        expect(@str.to_str).to eq "this is secret"
      end
    end
  end

  context "module methods" do
    include Circleci::Env::Vault

    describe "#secret_file_path" do
      it "should return secret file path" do
        expect(secret_file_path("name")).to eq "secret/name.vault"
      end
    end

    describe "#read" do
      it "should call Ansible::Valut.read()" do
        name = "name"
        password = "password"
        allow(Ansible::Vault).to receive(:read).with(path: secret_file_path(name), password: password)
        read(name, password)
      end
    end

    describe "#write" do
      it "should call Ansible::Valut.write()" do
        name = "name"
        value = "value"
        password = "password"
        allow(Ansible::Vault).to receive(:write).with(path: secret_file_path(name), plaintext: value, password: password)
        write(name, value, password)
      end
    end
  end
end
