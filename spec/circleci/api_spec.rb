require "spec_helper"
require "circleci/env/api"

describe Circleci::Env::Api do
  let!(:stub_connection) do
    Faraday.new do |builder|
      builder.response :raise_error
      builder.adapter :test, Faraday::Adapter::Test::Stubs.new do |stub|
        stub.get('/api/v1.1/project/github/hakobera/circleci-env-test-01/envvar') do
          [200, {}, JSON.generate([{ "name" => "KEY", "value" => "xxxxue" }])]
        end

        stub.get('/api/v1.1/project/github/hakobera/circleci-env-test-not-found/envvar') do
          [404, {}, ""]
        end

        stub.get('/api/v1.1/project/github/hakobera/circleci-env-test-timeout/envvar') do
          raise Faraday::TimeoutError
        end

        stub.get('/api/v1.1/project/github/hakobera/circleci-env-test-connection-failed/envvar') do
          raise Faraday::ConnectionFailed.new(StandardError.new("connection failed"))
        end

        stub.get('/api/v1.1/project/github/hakobera/circleci-env-test-bad-request/envvar') do
          raise Faraday::ClientError.new(StandardError.new("connection failed"), {status: 400, body: "bad request"})
        end

        stub.get('/api/v1.1/project/github/hakobera/circleci-env-test-client-error/envvar') do
          raise Faraday::ClientError.new(StandardError.new("connection failed"), {status: 500, body: "server error"})
        end

        stub.get('/api/v1.1/project/github/hakobera/circleci-env-test-01/envvar/KEY') do
          [200, {}, JSON.generate({ "name" => "KEY", "value" => "xxxxue" })]
        end

        stub.post('/api/v1.1/project/github/hakobera/circleci-env-test-01/envvar', { name: "NEW_KEY", value: "val" }) do
          [200, {}, JSON.generate({ "name" => "NEW_KEY", "value" => "xxxxl" })]
        end

        stub.delete('/api/v1.1/project/github/hakobera/circleci-env-test-01/envvar/NEW_KEY') do
          [200, {}, JSON.generate({ "message" => "ok" })]
        end
      end
    end
  end

  before do
    @api = Circleci::Env::Api.new(ENV['CIRCLECI_TOKEN'])
    allow(@api).to receive(:conn).and_return(stub_connection) if not ENV.has_key?('CIRCLECI')
  end

  describe "#list_envvars" do
    it "should get all envvars of a project" do
      res = @api.list_envvars("github/hakobera/circleci-env-test-01")
      expect(res).to eq([{ "name" => "KEY", "value" => "xxxxue" }])
    end

    it "should raise NotFound error" do
      expect { @api.list_envvars("github/hakobera/circleci-env-test-not-found") }.to raise_error(Circleci::Env::Api::NotFound)
    end

    if not ENV.has_key?('CIRCLECI')
      it "should raise TimeoutError" do
        expect { @api.list_envvars("github/hakobera/circleci-env-test-timeout") }.to raise_error(Circleci::Env::Api::TimeoutError)
      end

      it "should raise ServerError" do
        expect { @api.list_envvars("github/hakobera/circleci-env-test-connection-failed") }.to raise_error(Circleci::Env::Api::ServerError)
      end

      it "should raise BadRequest" do
        expect { @api.list_envvars("github/hakobera/circleci-env-test-bad-request") }.to raise_error(Circleci::Env::Api::BadRequest)
      end

      it "should raise ServerError" do
        expect { @api.list_envvars("github/hakobera/circleci-env-test-client-error") }.to raise_error(Circleci::Env::Api::ServerError)
      end
    end
  end

  describe "#get_envvar" do
    it "should get single envvar of a project" do
      res = @api.get_envvar("github/hakobera/circleci-env-test-01", "KEY")
      expect(res).to eq({ "name" => "KEY", "value" => "xxxxue" })
    end
  end

  describe "#add_envvar" do
    it "should add single envvar of a project" do
      res = @api.add_envvar("github/hakobera/circleci-env-test-01", "NEW_KEY", "val")
      expect(res).to eq({ "name" => "NEW_KEY", "value" => "xxxxl" })
    end
  end

  describe "#delete_envvar" do
    it "shuold delete single envar of a project" do
      res = @api.delete_envvar("github/hakobera/circleci-env-test-01", "NEW_KEY")
      expect(res).to eq({ "message" => "ok" })
    end
  end

  describe "#get_envvar" do
    it "should get single envvar of a project" do
      res = @api.get_envvar("github/hakobera/circleci-env-test-01", "KEY")
      expect(res).to eq({ "name" => "KEY", "value" => "xxxxue" })
    end
  end

  describe "#add_envvar" do
    it "should add single envvar of a project" do
      res = @api.add_envvar("github/hakobera/circleci-env-test-01", "NEW_KEY", "val")
      expect(res).to eq({ "name" => "NEW_KEY", "value" => "xxxxl" })
    end
  end

  describe "#delete_envvar" do
    it "shuold delete single envar of a project" do
      res = @api.delete_envvar("github/hakobera/circleci-env-test-01", "NEW_KEY")
      expect(res).to eq({ "message" => "ok" })
    end
  end
end
