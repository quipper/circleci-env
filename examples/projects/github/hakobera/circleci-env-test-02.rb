project "github/hakobera/circleci-env-test-02" do
  env(
    "KEY" => "value1",
    "Abc" => "value1",
    "SECRET_KEY" => secret("secret_key"),
  )

  Random.new.rand(15).times do |i|
    env "KEY#{i}" => "value#{i}"
  end
end
