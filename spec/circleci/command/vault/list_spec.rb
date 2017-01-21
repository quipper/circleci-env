require "spec_helper"
require "circleci/env/command/vault/list"

describe Circleci::Env::Command::Vault::List do
  let(:cmd) { Circleci::Env::Command::Vault::List.new(password: "pass") }

  describe "#run" do
    it "should create secret directory and call write" do
      allow(cmd).to receive(:secrets).and_yield("name1", "value1").and_yield("name2", "value2")
      expect{ cmd.run }.to output("\e[0;94;49m=== Secret Variables\e[0m\n\e[0;92;49mname1: \e[0mvalue1\n\e[0;92;49mname2: \e[0mvalue2\n").to_stdout
    end
  end
end
