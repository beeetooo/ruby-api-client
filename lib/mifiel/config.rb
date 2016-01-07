module Mifiel
  module Config
    class << self
      attr_reader :app_id, :app_secret

      def reset
        @app_id = nil
        @app_secret = nil
      end

      def app_id=(app_id)
        @app_id = app_id
        set_api_auth_credentials
      end

      def app_secret=(app_secret)
        @app_secret = app_secret
        set_api_auth_credentials
      end

      private

        def set_api_auth_credentials
          ActiveRestClient::Base.base_url = Mifiel::BASE_URL
          ActiveRestClient::Base.api_auth_credentials(app_id, app_secret)
          ActiveRestClient::Base.request_body_type = :json
        end
    end

    reset
  end
end
