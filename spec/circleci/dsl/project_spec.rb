require "spec_helper"
require "circleci/env/dsl/project"

describe Circleci::Env::DSL::Project do
  let(:project) { Circleci::Env::DSL::Project.define("vcs_type/username/repository") }

  describe "#projects" do
    it "shuoud add project for each call `define` method" do
      Circleci::Env::DSL::Project.projects = []

      expect {
        Circleci::Env::DSL::Project.define("vcs_type/username/repo1")
      }.to change{ Circleci::Env::DSL::Project.projects.count }.from(0).to(1)
      expect(Circleci::Env::DSL::Project.projects.last.id).to eq "vcs_type/username/repo1"

      expect {
        Circleci::Env::DSL::Project.define("vcs_type/username/repo2")
      }.to change{ Circleci::Env::DSL::Project.projects.count }.from(1).to(2)
      expect(Circleci::Env::DSL::Project.projects.last.id).to eq "vcs_type/username/repo2"
    end
  end

  describe "#id" do
    it "should return correct ID" do
      expect(project.is_a?(Circleci::Env::DSL::Project)).to eq true
      expect(project.id).to eq "vcs_type/username/repository"
    end
  end

  describe "#env" do
    it "should add Envvar instance to envvars" do
      expect { project.env("key1" => "val1") }.to change{ project.envvars.count }.from(0).to(1)
      expect(project.envvars.last.to_s).to eq "Envvar(key1=val1)"
      expect { project.env("key2" => "val2", "key3" => "val3") }.to change{ project.envvars.count }.from(1).to(3)
      expect(project.envvars.last.to_s).to eq "Envvar(key3=val3)"
    end
  end

  describe "secret" do
    it "should return nil if secret value not found" do
      expect(project.secret("not_exist_name")).to eq nil
    end

    it "should return secret value if exist" do
      Circleci::Env.app.add_secret("exist_name", "secret_value")
      expect(project.secret("exist_name")).to eq "secret_value"
    end
  end

  describe "#to_s" do
    it "should return formatted string" do
      expect(project.to_s).to eq "Project(id=vcs_type/username/repository)"
    end

    it "should include envvars if available" do
      project.env("key1" => "val1", "key2" => "val2")
      expect(project.to_s).to eq "Project(id=vcs_type/username/repository, envvars=[Envvar(key1=val1), Envvar(key2=val2))])"
    end
  end
end
