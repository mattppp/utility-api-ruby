#
# Copyright © 2015, TopCoder, Inc. All rights reserved.
#
# @author TCSASSEMBLER
# @version 0.1.0
#
require 'faraday'
require 'faraday_middleware'
require 'utilityapi/connection_errors'

module UtilityApi
  # Internal: Helper methods used by UtilityApi classes.
  # All methods are module methods and should be called on the module.
  module Helpers
    module_function

    # Internal: Create a Faraday connection with all the required options
    # correctly set.
    # Namely:
    # - The full endpoint URL is set.
    # - API authorization is performed with the provided token.
    # - Request body (if any) is encoded as json.
    # - HTTP Accept header is set to application/json.
    # - Response is parsed from json to Hash, if type is application/json.
    # - HTTP errors are handled by ConnectionErrorsHandler.
    # - HTTP redirects are followed.
    #
    # base_url     - The String with the API base URL
    #                (e.g 'https://utilityapi.com/api').
    # endpoint_url - The String with the endpoint URL relative to the base
    #                (e.g 'accounts').
    # access_token - The String with the API access token.
    #
    # Returns Faraday the created connection.
    def create_connection(base_url, endpoint_url, access_token)
      Faraday.new "#{base_url}/#{endpoint_url}" do |conn|
        conn.request :json

        conn.response :json, :content_type => 'application/json'
        conn.use ConnectionErrorsHandler
        conn.response :follow_redirects

        conn.adapter Faraday.default_adapter

        conn.headers[:Authorization] = "Token #{access_token}"
        conn.headers[:Accept] = 'application/json'
      end
    end
  end
end
