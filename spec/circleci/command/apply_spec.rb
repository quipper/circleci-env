require "spec_helper"
require "circleci/env/command/apply"

describe Circleci::Env::Command::Apply do
  before do
    Circleci::Env::DSL::Project.projects = []
  end

  let!(:stub_connection) do
    Faraday.new do |builder|
      builder.response :raise_error
      builder.adapter :test, Faraday::Adapter::Test::Stubs.new do |stub|
        stub.get('/api/v1.1/project/github/hakobera/circleci-env-test-01/envvar') do
          [200, {}, JSON.generate([{ "name" => "KEY1", "value" => "xxxxue0" }, { "name" => "KEY3", "value" => "xxxxue2" }, { "name" => "KEY4", "value" => "xxxxue4" }])]
        end

        stub.post('/api/v1.1/project/github/hakobera/circleci-env-test-01/envvar', { name: "KEY1", value: "value1" }) do
          [200, {}, JSON.generate({ "name" => "KEY1", "value" => "xxxxue1" })]
        end

        stub.post('/api/v1.1/project/github/hakobera/circleci-env-test-01/envvar', { name: "KEY2", value: "value2" }) do
          [200, {}, JSON.generate({ "name" => "KEY2", "value" => "xxxxue2" })]
        end

        stub.delete('/api/v1.1/project/github/hakobera/circleci-env-test-01/envvar/KEY3') do
          [200, {}, JSON.generate({ "message" => "ok" })]
        end

        stub.post('/api/v1.1/project/github/hakobera/circleci-env-test-01/envvar', { name: "KEY4", value: "value4" }) do
          [200, {}, JSON.generate({ "name" => "KEY4", "value" => "xxxxue4" })]
        end
      end
    end
  end

  context "not dry run" do
    let(:cmd) { Circleci::Env::Command::Apply.new(config: 'spec/data/Envfile.rb', token: 'token', password: 'pass') }

    before do
      api = Circleci::Env::Api.new(ENV['CIRCLECI_TOKEN'])
      allow(api).to receive(:conn).and_return(stub_connection)
      allow(cmd).to receive(:api).and_return(api)
      allow(cmd).to receive(:secrets).and_yield("key4", "value4")
      expect(api).to receive(:add_envvar).with("github/hakobera/circleci-env-test-01", "KEY1", "value1")
      expect(api).to receive(:add_envvar).with("github/hakobera/circleci-env-test-01", "KEY2", "value2")
      expect(api).to receive(:delete_envvar).with("github/hakobera/circleci-env-test-01", "KEY3")
      expect(api).to receive(:add_envvar).with("github/hakobera/circleci-env-test-01", "KEY4", "value4")
    end

    describe "#run" do
      it "should add/delete/update environment variables" do
        result = <<EOS
Load config from spec/data/Envfile.rb
Apply spec/data/Envfile.rb to CircleCI

=== github/hakobera/circleci-env-test-01

Progress: |
\e[0;92;49m  + add    KEY2=value2\e[0m
\e[0;31;49m  - delete KEY3\e[0m
\e[0;33;49m  ~ update KEY1=value1\e[0m
\e[0;94;49m  ? update KEY4=value4\e[0m

Result: |
  KEY1=xxxxue0
  KEY3=xxxxue2
  KEY4=xxxxue4
EOS
        expect{ cmd.run }.to output(result).to_stdout
      end
    end
  end

  context "dry run" do
    let(:cmd) { Circleci::Env::Command::Apply.new(config: 'spec/data/Envfile.rb', token: 'token', password: 'pass', dry_run: true) }

    before do
      api = Circleci::Env::Api.new(ENV['CIRCLECI_TOKEN'])
      allow(api).to receive(:conn).and_return(stub_connection)
      allow(cmd).to receive(:api).and_return(api)
      allow(cmd).to receive(:secrets).and_yield("name4", "value4")
      expect(api).to_not receive(:add_envvar)
      expect(api).to_not receive(:delete_envvar)
    end

    describe "#run" do
      it "should not call add/delete/update method" do
        result = <<EOS
Load config from spec/data/Envfile.rb
Apply spec/data/Envfile.rb to CircleCI (dry-run)

=== github/hakobera/circleci-env-test-01

Progress(dry-run): |
\e[0;92;49m  + add    KEY2=value2\e[0m
\e[0;31;49m  - delete KEY3\e[0m
\e[0;33;49m  ~ update KEY1=value1\e[0m
\e[0;94;49m  ? update KEY4=value4\e[0m
EOS
        expect{ cmd.run }.to output(result).to_stdout
      end
    end
  end
end
