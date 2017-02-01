require 'simplecov'

# save to CircleCI's artifacts directory if we're on CircleCI
if ENV['CIRCLE_ARTIFACTS']
  dir = File.join(ENV['CIRCLE_ARTIFACTS'], "coverage")
  SimpleCov.coverage_dir(dir)
end

SimpleCov.start do
  add_filter "/.bundle/"
  add_filter "/examples/"
  add_filter "/spec/"
end

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "circleci/env"

require "faraday"

# Override delete method because CircleCI needs body
module Faraday
  class Adapter
    class Test < Faraday::Adapter
      class Stubs
        def delete(path, body=nil, headers = {}, &block)
          new_stub(:delete, path, headers, body, &block)
        end
      end
    end
  end
end
