require 'simplecov'
SimpleCov.start do
  add_filter "/.bundle/"
  add_filter "/examples/"
  add_filter "/spec/"
end

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "circleci/env"
