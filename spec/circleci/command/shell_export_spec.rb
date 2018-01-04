require "spec_helper"
require "circleci/env/command/shell_export"

describe Circleci::Env::Command::ShellExport do
  let(:cmd) { Circleci::Env::Command::ShellExport.new(config: "spec/data/Envfile.rb", password: "pass", project_id: "github/quipper/circleci-env-test-01") }
  let(:ssh_key1) { ::SSHKey.generate }
  let(:ssh_key3) { ::SSHKey.generate }
  let(:ssh_key4) { ::SSHKey.generate }

  before do
    allow(cmd).to receive(:secrets)
                    .and_yield("key4", "value4")
                    .and_yield("ssh_key1", ssh_key1.private_key)
                    .and_yield("ssh_key3", ssh_key3.private_key)
                    .and_yield("ssh_key4", ssh_key4.private_key)
  end

  describe "#run" do
    it "should call read" do
      result = <<EOS
export KEY1='value1'
export KEY2='value2'
export KEY4='value4'
EOS
      expect{ cmd.run }.to output(result).to_stdout
    end
  end
end
