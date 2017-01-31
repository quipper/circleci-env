require "sshkey"

module Circleci
  module Env
    module DSL
      class SSHKey
        attr_reader :hostname

        def initialize(hostname, private_key)
          @hostname = hostname
          @key = ::SSHKey.new(private_key)
        rescue => e
          raise ArgumentError.new("private_key is invalid: #{e.message}")
        end

        def private_key
          @key.private_key
        end

        def fingerprint
          @key.md5_fingerprint
        end

        def changed?(current_fingerprint)
          fingerprint != current_fingerprint
        end

        def to_s
          "SSHKey(#{hostname}=#{fingerprint})"
        end
      end
    end
  end
end
