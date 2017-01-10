require "spec_helper"

describe Circleci::Env::DSL::Project do
  describe "#id" do
    it "should return correct ID" do
      project = Circleci::Env::DSL::Project.define("vcs_type/username/repository")
      expect(project.id).to eq "vcs_type/username/repository"
    end
  end
end
