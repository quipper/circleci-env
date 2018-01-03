project "github/quipper/circleci-env-test-01" do
  env(
    "KEY1" => "value1",
    "KEY2" => "value2",
    "KEY4" => secret("key4")
  )
  ssh_key(
    "test1.example.com" => secret("ssh_key1"),
    "test3.example.com" => secret("ssh_key3"),
    "test4.example.com" => secret("ssh_key4"),
  )
end
