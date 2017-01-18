require "spec_helper"
require "circleci/env/dsl/envvar"

describe Circleci::Env::DSL::Envvar do
  let(:envvar) { Circleci::Env::DSL::Envvar.new("name", "value") }

  describe "#initialize" do
    it "should set attributes" do
      expect(envvar.name).to eq "name"
      expect(envvar.value).to eq "value"
    end
  end

  describe "#to_s" do
    it "should return formatted string" do
      expect(envvar.to_s).to eq "Envvar(name=value)"
    end
  end
end
