project "github/hakobera/circleci-env-test-02" do
  env "KEY", "value1"
  env "Abc", "value1"
  Random.new.rand(15).times do |i|
    env "KEY#{i}", "value#{i}"
  end
  env "SECRET_KEY", secret("secret_key")
end
