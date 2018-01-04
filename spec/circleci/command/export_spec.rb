require "spec_helper"
require "circleci/env/command/export"
require "sshkey"

describe Circleci::Env::Command::Export do
  let(:cmd) { Circleci::Env::Command::Export.new(token: 'token', filter: '^github\/quipper\/circleci-env-test-01$') }
  let(:ssh_key) { ::SSHKey.generate }
  let!(:stub_connection) do
    Faraday.new do |builder|
      builder.response :raise_error
      builder.adapter :test, Faraday::Adapter::Test::Stubs.new do |stub|
        stub.get('/api/v1.1/projects') do
          [200, {}, JSON.generate([
            {
              "vcs_type" => "github",
              "username" => "quipper",
              "reponame" => "circleci-env-test-01",
              "ssh_keys" => [
                {
                  "hostname": "test1.example.com",
                  "public_key": ssh_key.ssh_public_key,
                  "fingerprint": ssh_key.md5_fingerprint
                }
              ]
            },
            {
              "vcs_type" => "github",
              "username" => "quipper",
              "reponame" => "circleci-env-test-02"
            },
          ])]
        end

        stub.get('/api/v1.1/project/github/quipper/circleci-env-test-01/envvar') do
          [200, {}, JSON.generate([{ "name" => "KEY1", "value" => "xxxxu1" }, { "name" => "KEY2", "value" => "xxxxu2" }])]
        end
      end
    end
  end

  before do
    api = Circleci::Env::Api.new(ENV['CIRCLECI_TOKEN'])
    allow(api).to receive(:conn).and_return(stub_connection)
    allow(cmd).to receive(:api).and_return(api)
  end

  describe "#run" do
    it "should export current project settings as file" do
      cmd.run
      out = File.read('projects/github/quipper/circleci-env-test-01.rb')
      expected = <<-EOS
project "github/quipper/circleci-env-test-01" do
  env(
    "KEY1" => "xxxxu1",
    "KEY2" => "xxxxu2",
  )
  ssh_key(
    "test1.example.com" => "<fingerprint> #{ssh_key.md5_fingerprint}",
  )
end
EOS
      expect(out).to eq expected
    end
  end
end
