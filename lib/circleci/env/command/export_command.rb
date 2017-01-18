require "circleci/env"
require "circleci/env/api"
require "circleci/env/dsl"
require "colorize"
require "fileutils"

module Circleci
  module Env
    module Command
      class ExportCommand
        def initialize(options)
          @options = options
        end

        def run
          api.list_projects.each do |project|
            FileUtils.mkdir_p("projects/#{dir(project)}")
            File.open("projects/#{id(project)}.rb", "w") do |f|
              f.puts "project \"#{id(project)}\" do"
              api.list_envvars(id(project)).each do |v|
                f.puts "  env \"#{v['name']}\", \"#{v['value']}\""
              end
              f.puts "end"
            end
          end
        end

        private

        def api
          @api ||= Api.new(@options.token)
        end

        def id(project)
          "#{dir(project)}/#{project['reponame']}"
        end

        def dir(project)
          "#{project['vcs_type']}/#{project['username']}"
        end
      end
    end
  end
end
