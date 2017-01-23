require "spec_helper"
require "circleci/env/command/vault/rekey"

describe Circleci::Env::Command::Vault::Rekey do
  let(:cmd) { Circleci::Env::Command::Vault::Rekey.new(current_password: "current", new_password: "new") }

  describe "#run" do
    it "should read all secrets and write using new password" do
      allow(cmd).to receive(:secrets).with("current").and_yield("name1", "value1").and_yield("name2", "value2")
      allow(cmd).to receive(:write).with("name1", "value1", "new")
      allow(cmd).to receive(:write).with("name2", "value2", "new")
      expect{ cmd.run }.to output("\n\e[0;94;49m=== Rekey Secret Variables\e[0m\nRekey name1\nRekey name2\n").to_stdout
    end
  end
end
