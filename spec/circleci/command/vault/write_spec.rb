require "spec_helper"
require "circleci/env/command/vault/write"

describe Circleci::Env::Command::Vault::Write do
  let(:cmd) { Circleci::Env::Command::Vault::Write.new(name: "name", value: "val", password: "pass") }

  describe "#run" do
    it "should create secret directory and call write" do
      allow(FileUtils).to receive(:mkdir_p).with("secret")
      allow(cmd).to receive(:write).with("name", "val", "pass")
      expect{ cmd.run }.to output("Write secret variable to secret/name.vault\n").to_stdout
    end
  end
end
