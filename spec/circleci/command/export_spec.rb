require "spec_helper"
require "circleci/env/command/export"

describe Circleci::Env::Command::Export do
  let(:cmd) { Circleci::Env::Command::Export.new(token: 'token', filter: '^github\/hakobera\/circleci-env-test-01$') }
  let!(:stub_connection) do
    Faraday.new do |builder|
      builder.response :raise_error
      builder.adapter :test, Faraday::Adapter::Test::Stubs.new do |stub|
        stub.get('/api/v1.1/projects') do
          [200, {}, JSON.generate([
            { "vcs_type" => "github", "username" => "hakobera", "reponame" => "circleci-env-test-01" },
            { "vcs_type" => "github", "username" => "hakobera", "reponame" => "circleci-env-test-02" },
          ])]
        end

        stub.get('/api/v1.1/project/github/hakobera/circleci-env-test-01/envvar') do
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
      out = File.read('projects/github/hakobera/circleci-env-test-01.rb')
      expected = <<-EOS
project "github/hakobera/circleci-env-test-01" do
  env(
    "KEY1" => "xxxxu1",
    "KEY2" => "xxxxu2",
  )
end
EOS
      expect(out).to eq expected
    end
  end
end
