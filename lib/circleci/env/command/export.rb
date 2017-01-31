require "circleci/env"
require "circleci/env/api"
require "circleci/env/dsl"
require "colorize"
require "fileutils"

module Circleci
  module Env
    module Command
      class Export
        def initialize(token:, filter: nil, ignore_empty: false)
          @token = token
          @filter = filter
          @ignore_empty = ignore_empty
        end

        def run
          api.list_projects.each do |project|
            next if @filter && !id(project).match(Regexp.new(@filter))
            envvars = api.list_envvars(id(project))
            next if @ignore_empty && envvars.empty?

            FileUtils.mkdir_p("projects/#{dir(project)}")
            File.open("projects/#{id(project)}.rb", "w") do |f|
              f.puts "project \"#{id(project)}\" do"
              export_envvars(f, envvars)
              export_ssh_keys(f, project)
              f.puts "end"
            end
          end
        end

        private

        def api
          @api ||= Api.new(@token)
        end

        def id(project)
          "#{dir(project)}/#{project['reponame']}"
        end

        def dir(project)
          "#{project['vcs_type']}/#{project['username']}"
        end

        def export_envvars(f, envvars)
          if !envvars.empty?
            f.puts("  env(")
            envvars.each do |v|
              f.puts "    \"#{v['name']}\" => \"#{v['value']}\","
            end
            f.puts("  )")
          end
        end

        def export_ssh_keys(f, project)
          ssh_keys = project['ssh_keys']
          if ssh_keys && !ssh_keys.empty?
            f.puts("  ssh_key(")
            ssh_keys.each do |v|
              f.puts "    \"#{v['hostname']}\" => \"<fingerprint> #{v['fingerprint']}\","
            end
            f.puts("  )")
          end
        end
      end
    end
  end
end
