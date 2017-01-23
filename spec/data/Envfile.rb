project "github/hakobera/circleci-env-test-01" do
  env(
    "KEY1" => "value1",
    "KEY2" => "value2",
    "KEY4" => secret("key4")
  )
end
