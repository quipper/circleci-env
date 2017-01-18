require "faraday"
require "faraday_middleware"
require "json"

module Circleci
  module Env
    class Api
      class ApiError < StandardError; end
      class BadRequest < ApiError; end
      class NotFound < ApiError; end
      class ServerError < ApiError; end
      class TimeoutError < ApiError; end

      def initialize(token)
        @token = token
      end

      # https://circleci.com/docs/api/#list-environment-variables
      def list_envvars(project_id)
        get "/api/v1.1/project/#{project_id}/envvar"
      end

      def get_envvar(project_id, name)
        get "/api/v1.1/project/#{project_id}/envvar/#{name}"
      end

      def add_envvar(project_id, name, value)
        post "/api/v1.1/project/#{project_id}/envvar", { name: name, value: value }
      end

      def delete_envvar(project_id, name)
        delete "/api/v1.1/project/#{project_id}/envvar/#{name}"
      end

      private

      def conn
        @conn ||= Faraday.new(url: "https://circleci.com") do |builder|
          builder.request :basic_auth, @token, ""
          builder.request :json
          builder.request :retry,
            exceptions: [Faraday::TimeoutError, Faraday::ConnectionFailed, Faraday::ClientError],
            retry_if: ->(env, _exception) { !(400..499).include?(env.status) }
          builder.response :raise_error
          builder.response :logger if ENV['CIRCLECI_ENV_DEBUG']
          builder.adapter Faraday.default_adapter
        end
      end

      def get(path)
        request { conn.get(path) }
      end

      def post(path, body)
        request { conn.post(path, body) }
      end

      def delete(path, body=nil)
        request { conn.delete(path, body) }
      end

      def request
        begin
          response = yield
          JSON.parse(response.body)
        rescue Faraday::ResourceNotFound => e
          raise NotFound, e.message
        rescue Faraday::TimeoutError => e
          raise TimeoutError, e.message
        rescue Faraday::ConnectionFailed => e
          raise ServerError, e.message
        rescue Faraday::ClientError => e
          raise BadRequest, e.response[:body] if e.response[:status] == 400
          raise ServerError, e.message
        end
      end
    end
  end
end
