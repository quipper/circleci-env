# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'circleci/env/version'

Gem::Specification.new do |spec|
  spec.name          = "circleci-env"
  spec.version       = Circleci::Env::VERSION
  spec.authors       = ["Kazuyuki Honda"]
  spec.email         = ["sre@quipper.com"]

  spec.summary       = %q{A tool to manage CircleCI Environment Variables using CircleCI API.}
  spec.homepage      = "https://github.com/quipper/circleci-env"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "ansible-vault", "~> 0.2.1"
  spec.add_runtime_dependency "commander", "~> 5.0.0"
  spec.add_runtime_dependency "colorize", "~> 1.1.0"
  spec.add_runtime_dependency "faraday", "~> 1.10.4"
  spec.add_runtime_dependency "faraday_middleware", "~> 1.2.0"
  spec.add_runtime_dependency "sshkey", "~> 3.0.0"

  spec.add_development_dependency "bundler", "~> 4.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "simplecov", "~> 0.12.0"
end
