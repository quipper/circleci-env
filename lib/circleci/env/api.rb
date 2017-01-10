require "faraday"
require "faraday_middleware"
require "json"

module Circleci
  module Env
    class Api
      def initialize(token)
        @token = token
      end

      def list_envvars(project_id)
        get "/api/v1.1/project/#{project_id}/envvar"
      end

      def get_envvar(project_id, name)
        get "/api/v1.1/project/#{project_id}/envvar/#{name}"
      end

      def add_envvar(project_id, name, value)
        post "/api/v1.1/project/#{project_id}/envvar", { name: name, value: value }
      end

      private

      def conn
        @conn ||= Faraday.new(url: "https://circleci.com") do |builder|
          builder.request  :basic_auth, @token, ""
          builder.request  :json
          builder.response :logger if ENV['CIRCLECI_ENV_DEBUG']
          builder.adapter  Faraday.default_adapter
        end
      end

      def get(path)
        response = conn.get(path)
        if response.success?
          JSON.parse(response.body)
        else
          nil
        end
      end

      def post(path, body)
        response = conn.post(path, body)
        if response.success?
          JSON.parse(response.body)
        else
          nil
        end
      end
    end
  end
end
