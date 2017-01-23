require "spec_helper"
require "circleci/env/command/vault/read"

describe Circleci::Env::Command::Vault::Read do
  let(:cmd) { Circleci::Env::Command::Vault::Read.new(name: "name", password: "pass") }

  describe "#run" do
    it "should call read" do
      allow(cmd).to receive(:read).with("name", "pass").and_return("secret value")
      expect{ cmd.run }.to output("Read secret variable from secret/name.vault\nsecret value\n").to_stdout
    end
  end
end
