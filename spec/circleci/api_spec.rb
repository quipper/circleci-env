require "spec_helper"

describe Circleci::Env::Api do
  before do
    @api = Circleci::Env::Api.new(ENV['CIRCLECI_TOKEN'])
  end

  describe "#list_envvars" do
    it "should get all envvars of a project" do
      res = @api.list_envvars("github/hakobera/circleci-env-test-01")
      expect(res).to eq([
        { "name" => "KEY", "value" => "xxxxue" },
        { "name" => "NEW_KEY", "value" => "xxxxl" },
      ])
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
end
