project "github/hakobera/circleci-env-test-02" do
  env "KEY", "value1"
  10.times do |i|
    env "KEY#{i}", "value#{i}"
  end
  #env "SECRET_KEY", secrets["secret_key"]
end
