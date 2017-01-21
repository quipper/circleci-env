# circleci-env

`circleci-env` is a tool to manage CircleCI Environment Variables using CircleCI API.

<!-- TOC depthFrom:2 -->

- [Installation](#installation)
- [Usage](#usage)
- [Envfile examples](#envfile-examples)
  - [For single project](#for-single-project)
  - [For multiple project](#for-multiple-project)
    - [Envfile](#envfile)
    - [For each project](#for-each-project)
- [Secret variables](#secret-variables)
  - [Project structure](#project-structure)
  - [Write secret variable](#write-secret-variable)
  - [Read secret variable](#read-secret-variable)
  - [List all secret variables](#list-all-secret-variables)
- [Export existing project's envvars](#export-existing-projects-envvars)
  - [Export all projects which you can access](#export-all-projects-which-you-can-access)
  - [Export single project](#export-single-project)
  - [Export projects which muched by by filter](#export-projects-which-muched-by-by-filter)
  - [Export folder structure](#export-folder-structure)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)

<!-- /TOC -->

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

```sh
$ circleci-env --help                                                                                                              (git)-[update-readme]  (m1)
  circleci-env

  circleci-env is a tool to manage CircleCI environment variables.

  Commands:
    apply       Apply CiecleCI environment variables from config files
    export      Export CiecleCI environment variables from API
    help        Display global or [command] help documentation
    vault list  List all secret variables
    vault read  Read secret variable
    vault write Write secret variable

  Global Options:
    -h, --help           Display help documentation
    -v, --version        Display version information
    -t, --trace          Display backtrace when an error occurs
```

```rb
$ export CIRCLECI_TOKEN='...'
$ vi Envfile.rb
$ circleci-env apply --dry-run
$ circleci-env apply
```

## Envfile examples

### For single project

```rb
project "github/user/repo" do
  env(
    "KEY1" => "value1",
    "KEY2" => "Value2",
  )
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
  env(
    "KEY1" => "value1",
    "KEY2" => "value2",
  )
end
```

```rb
project "github/user/repo2" do
  env(
    "KEY1" => "value1",
    "KEY2" => "value2",
  )
end
```

You can see real example in [examples](./examples) folder.

## Secret variables

`circleci-env` support vault feature to manage secret values like API key.
You can read/write encrypted secret value and refer it as variable in `Envfile.rb`.

### Project structure

```
|- Envfile
|- secret
   |- secret_key.vault
   |- some_api_token.vault
   |- ...
```

All secret variables are stored in file in directory named `secret`.
Each file include value of secret varaiable and must have `.vault` file extention.

In `Envfile.rb`, you can refer these variables by filename without extention using `secret` method.
For example, you can refer secret value in `secrete_key.vault` like:

```rb
project "github/user/repo1" do
  env(
    "NORMAL_KEY" => "value1",
    "SECRET_KEY" => secret("secret_key")
  )
end
```

### Write secret variable

To encrypt secret variable and write it to file, use `valut write` command.

```sh
$ export CIRCLECI_ENV_PASSWORD=xxx
$ circleci-env vault write secret_key "Some secret value"
```

This command encrypt values and write it into a file named `secret_key.valut` in `secret` directory.

### Read secret variable

To decrypt secret variable from, use `valut read` command.

```sh
$ export CIRCLECI_ENV_PASSWORD=xxx
$ circleci-env vault read secret_key
#=> "Some secret value"
```

This command read a secret varable from `secret_key.valut` in `secret` directory.

### List all secret variables

To list all secret variables, use `vault list` command.

```sh
$ export CIRCLECI_ENV_PASSWORD=xxx
$ circleci-env vault list                                                                                                                                                                                                 (git)-[master] -
=== Secret Vars
key1: value1
key2: value2
```

## Export existing project's envvars

`circleci-env` provide command to export existing project's envvars.
Unfortunately CircleCI API returns masked value, you cannot get raw value of envars.
So you have to update all values in config file before apply it.

### Export all projects which you can access

```sh
$ circleci-env export
```

### Export single project

```sh
$ circleci-env export --filter "github/username/repo"
```

### Export projects which muched by by filter

You can filter projects by regular expression

```sh
$ circleci-env export --filter "^github\/username\/.*$"
```

### Export folder structure

Export feature create a file per projects following folder structure like this:

```
|- projects
   |- github
      |- user
      |  |- repo1.rb
      |  |- repo2.rb
      |
      |- organization
         |- repo3.rb
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/quipper/circleci-env.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
