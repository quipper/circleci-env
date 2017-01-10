require "spec_helper"

describe Circleci::Env do
  it "has a version number" do
    expect(Circleci::Env::VERSION).not_to be nil
  end
end
