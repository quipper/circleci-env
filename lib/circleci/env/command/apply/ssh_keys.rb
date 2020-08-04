module Circleci
  module Env
    module Command
      module ApplySSHKeys
        def apply_ssh_keys(project)
          if !ssh_keys_no_change?(project)
            puts "ssh_keys:"
            add_ssh_keys(project)
            delete_ssh_keys(project)
            update_ssh_keys(project)
          end
        end

        def show_ssh_keys(project)
          puts "ssh_keys:"
          api.get_settings(project.id)['ssh_keys'].each do |ssh_key|
            puts "  #{ssh_key['hostname']}=#{ssh_key['fingerprint']}"
          end
        end

        private

        def current_ssh_keys(project)
          @current_ssh_keys ||= {}
          @current_ssh_keys[project.id] ||= api.get_settings(project.id)['ssh_keys'].map{|s| [s['hostname'], s['fingerprint']]}.to_h
        end

        def added_ssh_keys(project)
          project.ssh_keys.select{|s| !current_ssh_keys(project).has_key?(s.hostname)}
        end

        def updated_ssh_keys(project)
          project.ssh_keys.select{|s| current_ssh_keys(project).has_key?(s.hostname) && current_ssh_keys(project)[s.hostname] != s.fingerprint}
        end

        def deleted_ssh_keys(project)
          defined_hostnames = project.ssh_keys.map(&:hostname)
          current_ssh_keys(project).select{|k, v| !defined_hostnames.include?(k)}
        end

        def add_ssh_keys(project)
          added_ssh_keys(project).each do |ssh_key|
            log_add("#{ssh_key.hostname}=#{ssh_key.fingerprint}")
            api.add_ssh_key(project.id, ssh_key.hostname, ssh_key.private_key) unless dry_run?
          end
        end

        def delete_ssh_keys(project)
          deleted_ssh_keys(project).each do |hostname, fingerprint|
            log_delete("#{hostname}=#{fingerprint}")
            api.delete_ssh_key(project.id, hostname, fingerprint) unless dry_run?
          end
        end

        def update_ssh_keys(project)
          updated_ssh_keys(project).each do |ssh_key|
            current_fingerprint = current_ssh_keys(project)[ssh_key.hostname]
            log_update("#{ssh_key.hostname}=#{current_fingerprint} => #{ssh_key.fingerprint}")
            api.delete_ssh_key(project.id, ssh_key.hostname, current_fingerprint) unless dry_run?
            api.add_ssh_key(project.id, ssh_key.hostname, ssh_key.private_key) unless dry_run?
          end
        end

        def ssh_keys_no_change?(project)
          added_ssh_keys(project).empty? && deleted_ssh_keys(project).empty? && updated_ssh_keys(project).empty?
        end
      end
    end
  end
end
