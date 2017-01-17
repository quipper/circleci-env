# circleci-env

`circleci-env` is a tool to manage CircleCI Environment Variables using CircleCI API.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'circleci-env'
```

And then execute:

```sh
$ bundle
```

Or install it yourself as:

```sh
$ gem install circleci-env
```

## Usage

```rb
$ export CIRCLECI_TOKEN='...'
$ vi Envfile
$ ccenv apply --dry-run
$ ccenv apply
```

## Envfile examples

### For single project

```rb
project "github/user/repo" do
  env "KEY1", "value1"
  env "KEY2", "value2
end
```

### For multiple project

`circleci-env` recommand to use following project structure.

```
|- Envfile
|- projects
   |- github
      |- user
      |  |- repo1.rb
      |  |- repo2.rb
      |
      |- organization
         |- repo3.rb
```

#### Envfile

```rb
#
# If you want to write common setting, write here
#

Dir[File.expand_path('../projects', __FILE__) + '/**/*.rb'].each do |file|
  require file
end
```

#### For each project

```rb
project "github/user/repo1" do
  env "KEY1", "value1"
  env "KEY2", "value2
end
```

```rb
project "github/user/repo2" do
  env "KEY1", "value1"
  env "KEY2", "value2
end
```

You can see real example in [examples](./examples) folder.

## Secret values

`circleci-env` support vault feature to manage secret values like API key.

### Project structure

All secret value files include one directory named `secret` like this:

```
|- Envfile
|- secret
   |- secret_key.vault
   |- some_api_token.vault
   |- ...
```

For each file, it must include one secret value and has `.vault` extention.
In `Envfile`, you can refer these values by filename without extention.
For example, you can refer secret value in `secrete_key.vault` like:

```rb
project "github/user/repo1" do
  env "SECRET_KEY", secret("secret_key")
end
```

### Write secret value

Run following command:

```sh
$ circleci-env vault --password xxx --write --key secret_key --value "Some secret value"
```

This command create a file named `secret_key.valut` in `secret` directory.

### Read secret value

Run following command:

```sh
$ circleci-env vault --password xxx --read --key secret_key
#=> "Some secret value"
```

This command read a secret value from `secret_key.valut` in `secret` directory.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hakobera/circleci-env.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
