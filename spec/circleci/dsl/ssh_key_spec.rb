require "spec_helper"
require "circleci/env/dsl/ssh_key"

describe Circleci::Env::DSL::SSHKey do
  let(:key)     { ::SSHKey.generate }
  let(:ssh_key) { Circleci::Env::DSL::SSHKey.new("host1.example.com", key.private_key) }

  describe "#initialize" do
    it "should set attributes" do
      expect(ssh_key.hostname).to eq "host1.example.com"
      expect(ssh_key.private_key).to eq key.private_key
      expect(ssh_key.fingerprint).to eq key.md5_fingerprint
    end
  end

  describe "#to_s" do
    it "should return formatted string" do
      expect(ssh_key.to_s).to eq "SSHKey(host1.example.com=#{key.md5_fingerprint})"
    end
  end
end
