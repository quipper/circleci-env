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
      it "should call Ansible::Vault.read()" do
        name = "name"
        password = "password"
        allow(Ansible::Vault).to receive(:read).with(path: secret_file_path(name), password: password)
        read(name, password)
      end
    end

    describe "#write" do
      it "should call Ansible::Vault.write()" do
        name = "name"
        value = "value"
        password = "password"
        allow(Ansible::Vault).to receive(:write).with(path: secret_file_path(name), plaintext: value, password: password)
        write(name, value, password)
      end
    end

    describe "#secrets" do
      it "should read all secret files" do
        allow(Dir).to receive(:glob)
                      .and_yield("spec/data/secret/name1.vault")
                      .and_yield("spec/data/secret/name2.vault")

        results = []
        secrets("password") do |name, value|
          results << [name, value]
        end
        expect(results.count).to eq 2
        expect(results[0]).to eq ["name1", "value1"]
        expect(results[1]).to eq ["name2", "value2"]
      end
    end
  end
end
