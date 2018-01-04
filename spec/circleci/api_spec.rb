require "spec_helper"
require "circleci/env/api"
require "sshkey"

describe Circleci::Env::Api do
  let(:ssh_key) { ::SSHKey.generate }
  let!(:stub_connection) do
    Faraday.new do |builder|
      builder.response :raise_error
      builder.adapter :test, Faraday::Adapter::Test::Stubs.new do |stub|
        stub.get('/api/v1.1/projects') do
          [200, {}, JSON.generate([
            { "vcs_type" => "github", "username" => "quipper", "reponame" => "circleci-env-test-01" },
            { "vcs_type" => "github", "username" => "quipper", "reponame" => "circleci-env-test-02" },
          ])]
        end

        stub.get('/api/v1.1/project/github/quipper/circleci-env-test-01/envvar') do
          [200, { content_type: 'application/json' }, JSON.generate([{ "name" => "KEY", "value" => "xxxxue" }])]
        end

        stub.get('/api/v1.1/project/github/quipper/circleci-env-test-not-found/envvar') do
          [404, {}, ""]
        end

        stub.get('/api/v1.1/project/github/quipper/circleci-env-test-timeout/envvar') do
          raise Faraday::TimeoutError
        end

        stub.get('/api/v1.1/project/github/quipper/circleci-env-test-connection-failed/envvar') do
          raise Faraday::ConnectionFailed.new(StandardError.new("connection failed"))
        end

        stub.get('/api/v1.1/project/github/quipper/circleci-env-test-bad-request/envvar') do
          raise Faraday::ClientError.new(StandardError.new("connection failed"), {status: 400, body: "bad request"})
        end

        stub.get('/api/v1.1/project/github/quipper/circleci-env-test-client-error/envvar') do
          raise Faraday::ClientError.new(StandardError.new("connection failed"), {status: 500, body: "server error"})
        end

        stub.get('/api/v1.1/project/github/quipper/circleci-env-test-01/envvar/KEY') do
          [200, {}, JSON.generate({ "name" => "KEY", "value" => "xxxxue" })]
        end

        stub.post('/api/v1.1/project/github/quipper/circleci-env-test-01/envvar', { name: "NEW_KEY", value: "val" }) do
          [200, {}, JSON.generate({ "name" => "NEW_KEY", "value" => "xxxxl" })]
        end

        stub.delete('/api/v1.1/project/github/quipper/circleci-env-test-01/envvar/NEW_KEY') do
          [200, {}, JSON.generate({ "message" => "ok" })]
        end

        stub.post('/api/v1.1/project/github/quipper/circleci-env-test-01/ssh-key', { hostname: "host1.example.com", private_key: ssh_key.private_key }) do
          [200, {}, ""]
        end

        stub.delete('/api/v1.1/project/github/quipper/circleci-env-test-01/ssh-key', { hostname: "host1.example.com", fingerprint: ssh_key.md5_fingerprint }) do
          [200, {}, ""]
        end
      end
    end
  end

  ##
  # [NOTE]
  # In CircleCI, this spec calls actual CircleCI API.
  # CIRCLECI_TOKEN will use quippo@quipper.com's one, and the token operates the settings of the repositories below.
  # - https://circleci.com/gh/quipper/circleci-env-test-01/edit
  # - https://circleci.com/gh/quipper/circleci-env-test-02/edit
  ##
  before do
    @api = Circleci::Env::Api.new(ENV['CIRCLECI_TOKEN'])
    allow(@api).to receive(:conn).and_return(stub_connection) if not ENV.has_key?('CIRCLECI')
  end

  describe "#list_projects" do
    it "should get all followed projects" do
      res = @api.list_projects

      p1 = res.find{|r| r['reponame'] == 'circleci-env-test-01'}
      expect(p1['vcs_type']).to eq 'github'
      expect(p1['username']).to eq 'quipper'

      p2 = res.find{|r| r['reponame'] == 'circleci-env-test-02'}
      expect(p2['vcs_type']).to eq 'github'
      expect(p2['username']).to eq 'quipper'
    end
  end

  describe "#list_envvars" do
    it "should get all envvars of a project" do
      res = @api.list_envvars("github/quipper/circleci-env-test-01")
      expect(res).to eq([{ "name" => "KEY", "value" => "xxxxue" }])
    end

    it "should raise NotFound error" do
      expect { @api.list_envvars("github/quipper/circleci-env-test-not-found") }.to raise_error(Circleci::Env::Api::NotFound)
    end

    if not ENV.has_key?('CIRCLECI')
      it "should raise TimeoutError" do
        expect { @api.list_envvars("github/quipper/circleci-env-test-timeout") }.to raise_error(Circleci::Env::Api::TimeoutError)
      end

      it "should raise ServerError" do
        expect { @api.list_envvars("github/quipper/circleci-env-test-connection-failed") }.to raise_error(Circleci::Env::Api::ServerError)
      end

      it "should raise BadRequest" do
        expect { @api.list_envvars("github/quipper/circleci-env-test-bad-request") }.to raise_error(Circleci::Env::Api::BadRequest)
      end

      it "should raise ServerError" do
        expect { @api.list_envvars("github/quipper/circleci-env-test-client-error") }.to raise_error(Circleci::Env::Api::ServerError)
      end
    end
  end

  describe "#get_envvar" do
    it "should get single envvar of a project" do
      res = @api.get_envvar("github/quipper/circleci-env-test-01", "KEY")
      expect(res).to eq({ "name" => "KEY", "value" => "xxxxue" })
    end
  end

  describe "#add_envvar" do
    it "should add single envvar of a project" do
      res = @api.add_envvar("github/quipper/circleci-env-test-01", "NEW_KEY", "val")
      expect(res).to eq({ "name" => "NEW_KEY", "value" => "xxxxl" })
    end
  end

  describe "#delete_envvar" do
    it "shuold delete single envar of a project" do
      res = @api.delete_envvar("github/quipper/circleci-env-test-01", "NEW_KEY")
      expect(res).to eq({ "message" => "ok" })
    end
  end

  describe "#add_ssh_key and #delete_ssh_key" do
    it "should add ssh key of a project" do
      hostname = "host1.example.com"
      # Add an SSH key
      res = @api.add_ssh_key("github/quipper/circleci-env-test-01", hostname, ssh_key.private_key)
      expect(res).to eq("")

      if ENV['CIRCLECI']
        settings = @api.get_settings("github/quipper/circleci-env-test-01")
        fingerprints = settings["ssh_keys"].select{|k| k["hostname"] == hostname}.map{|k| k["fingerprint"]}
        expect(fingerprints).to include(ssh_key.md5_fingerprint)
      end

      # Delete the key
      res = @api.delete_ssh_key("github/quipper/circleci-env-test-01", hostname, ssh_key.md5_fingerprint)
      expect(res).to eq("")

      if ENV['CIRCLECI']
        settings = @api.get_settings("github/quipper/circleci-env-test-01")
        fingerprints = settings["ssh_keys"].select{|k| k["hostname"] == hostname}.map{|k| k["fingerprint"]}
        expect(fingerprints).not_to include(ssh_key.md5_fingerprint)
      end
    end
  end
end
