# circleci-env

`circleci-env` is a tool to manage CircleCI Environment Variables and Settings using CircleCI API.

<!-- TOC depthFrom:2 -->

- [Installation](#installation)
- [Supported Settings](#supported-settings)
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
  - [Change password](#change-password)
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

First, download the source:

```ruby
$ git clone git@github.com:quipper/circleci-env.git
```

Build the gem:

```sh
$ cd circleci-env && gem build circleci-env.gemspec
```

Install it (the filename/version may vary)

```sh
$ gem install circleci-env-0.2.0.gem
```

## Supported Settings

- [Environment Variables](https://circleci.com/docs/environment-variables/#setting-environment-variables-for-all-commands-without-adding-them-to-git)
- [SSH Keys](https://circleci.com/docs/api/#ssh-keys)

## Usage

```sh
$ circleci-env --help
  circleci-env

  circleci-env is a tool to manage CircleCI environment variables.

  Commands:
    apply        Apply CircleCI environment variables from config files
    export       Export CircleCI environment variables from API
    help         Display global or [command] help documentation
    shell-export Shew a shell expression to export all environment variables on a project
    vault list   List all secret variables
    vault read   Read secret variable
    vault rekey  Change password of all secret variables
    vault write  Write secret variable

  Global Options:
    -h, --help           Display help documentation 
    -v, --version        Display version information 
    -t, --trace          Display backtrace when an error occurs 
```

```sh
$ export CIRCLECI_TOKEN='...'
$ vi Envfile.rb
$ circleci-env apply -c Envfile.rb --dry-run
$ circleci-env apply -c Envfile.rb
```

Envfile.rb is like this:

```rb
project "github/username/repot-01" do
  env(
    "KEY1" => "XYZ",
    "KEY3" => "ABCDEF",
    "SECRET_KEY1" => secret("secret_key1")
  )
  ssh_key(
    "test1.example.com" => secret("ssh_key1"),
    "test3.example.com" => secret("ssh_key3"),
  )
end
```

Command output is like this:

```sh
Load config from Envfile.rb
Apply Envfile.rb to CircleCI

=== github/username/repo1

Progress: |
envvars:
  + add    KEY1=XYZ
  - delete KEY2
  ? update SECRET_KEY1=xxxxQ
  ~ update KEY3=ABCDEF
ssh_keys:
  + add    test1.example.com=<ssh key fingerprint>
  - delete test2.example.com=<ssh key fingerprint>
  ~ update test3.example.com=<ssh key fingerprint>

Result: |
envvars:
  KEY1=xxxxZ
  SECRET_KEY1=xxxxQ
  KEY3=xxxxEF
ssh_keys:
  test1.example.com=<ssh key fingerprint>
  test3.example.com=<ssh key fingerprint>
```

There are 4 progress statuses

- `+ add`: Add new environment variable
- `- delete`: Delete existing environment variable
- `? update`: Suffix matches current value. Maybe value is not update.
- `~ update`: Update existing environment variable

`? update` is tricky status, but it's depends on CircleCI REST API specification.
CircleCI REST API return only masked value (show few character of raw value),
so we cannot match exactly between current and new values.

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

`circleci-env` recommends to use following project structure.

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

All secret variables are stored in file in a directory named `secret`, or you can specify any directory with the environment variable `CIRCLECI_ENV_SECRET_DIR`.
Each file includes a value of the secret and must have `.vault` file extension.

In `Envfile.rb`, you can refer to these variables by filename without extension using `secret` method.
For example, you can refer secret value in `secrete_key.vault` like:

```rb
project "github/user/repo1" do
  env(
    "NORMAL_KEY" => "value1",
    "SECRET_KEY" => secret("secret_key")
  )
  ssh_key(
    "host1.example.com" => secret("sshkey-host1-example-com"),
    "host2.example.com" => secret("sshkey-host2-example-com"),
  )
end
```

### Write secret variable

To encrypt secret variable and write it to file, use `vault write` command.

```sh
$ export CIRCLECI_ENV_PASSWORD=xxx
$ circleci-env vault write secret_key "Some secret value"
```

To write secret variable via file, use `--input-file` option.

```sh
$ export CIRCLECI_ENV_PASSWORD=xxx
$ circleci-env vault write secret_key --input-file secret_file
```

This command encrypt values and write it into a file named `secret_key.vault` in `secret` directory.

### Read secret variable

To decrypt secret variable from, use `vault read` command.

```sh
$ export CIRCLECI_ENV_PASSWORD=xxx
$ circleci-env vault read secret_key
#=> "Some secret value"
```

This command read a secret variable from `secret_key.vault` in `secret` directory.

### List all secret variables

To list all secret variables, use `vault list` command.

```sh
$ export CIRCLECI_ENV_PASSWORD=xxx
$ circleci-env vault list                                                                                                                                                                                                 (git)-[master] -
=== Secret Vars
key1: value1
key2: value2
```

### Change password

To change password of all secret variables, use `vault rekey` command.

```sh
$ circleci-env vault rekey
Current Password: ***
New Password: ***

=== Rekey Secret Variables
Rekey key1
Rekey key2
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

## Show a shell expression to export all environment variables on a project. 
`circleci-env` can show all environment variables on a project as a shell export's expression.

```sh
$ export CIRCLECI_ENV_PASSWORD=xxx
$ circleci-env shell-export github/username/repo
export KEY1='VALUE1'
export KEY2='VALUE2'
export KEY3='VALUE3'
```

So you can export them with `eval`

```sh
$ eval "$(circleci-env shell-export github/username/repo)"
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/quipper/circleci-env.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
