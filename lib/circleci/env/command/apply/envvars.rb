module Circleci
  module Env
    module Command
      module ApplyEnvvars
        CIRCLECI_MASK_PREFIX = 'xxxx'

        def apply_envvars(project)
          puts "envvars:"
          add_envvars(project)
          delete_envvars(project)
          update_envvars(project)
        end

        private

        def current_envvars(project)
          @current_envvars ||= {}
          @current_envvars[project.id] ||= api.list_envvars(project.id).map{|e| [e['name'], e['value']]}.to_h
        end

        def added_envvars(project)
          current_names = current_envvars(project).keys
          project.envvars.select{|e| !current_names.include?(e.name)}
        end

        def updated_envvars(project)
          current_names = current_envvars(project).keys
          project.envvars.select{|e| current_names.include?(e.name)}
        end

        def deleted_envvars(project)
          defined_names = project.envvars.map(&:name)
          current_envvars(project).select{|k, v| !defined_names.include?(k)}
        end

        def add_envvars(project)
          added_envvars(project).each do |envvar|
            log_add("#{envvar.name}=#{envvar.value.to_s}")
            api.add_envvar(project.id, envvar.name, envvar.value.to_str) unless dry_run?
          end
        end

        def delete_envvars(project)
          deleted_envvars(project).each do |name, value|
            log_delete(name)
            api.delete_envvar(project.id, name) unless dry_run?
          end
        end

        def update_envvars(project)
          updated_envvars(project).each do |envvar|
            # CircleCI masked value prefix is 'xxxx', so remove it.
            current_suffix = current_envvars(project)[envvar.name][CIRCLECI_MASK_PREFIX.length..-1]
            log_update("#{envvar.name}=#{envvar.value.to_s}", envvar.changed?(current_suffix))
            api.add_envvar(project.id, envvar.name, envvar.value.to_str) unless dry_run?
          end
        end
      end
    end
  end
end
