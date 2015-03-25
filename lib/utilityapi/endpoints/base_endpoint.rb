#
# Copyright © 2015, TopCoder, Inc. All rights reserved.
#
# @author TCSASSEMBLER
# @version 0.1.0
#
require 'utilityapi/model/add_modify_requirements'
require 'utilityapi/asyncable'
require 'utilityapi/helpers'

module UtilityApi
  module Endpoints
    # Public: Common API methods supported for all endpoints.
    # This class is to be subclassed, not instantiated directly.
    # Supports performing all the methods asynchronously.
    class BaseEndpoint
      include Asyncable

      # Public: Initialize an endpoint api object.
      #
      # base_url     - The String with the base URL of the API.
      # access_token - The String with a generated API access token.
      def initialize(access_token, base_url = BASE_URL)
        @connection = Helpers.create_connection(
          base_url,
          self.class::ENDPOINT_URL,
          access_token
        )
      end

      # Public: Get an object.
      # Currently, you can only request objects that you have added.
      # In future updates, we may start to allow requests of other objects
      # if their owners have authorized you to see them.
      #
      # uid - The String with an object uid.
      #
      # Returns Object as an instance of the corresponding model.
      # Raises Errors::NotFound if the uid is not found (HTTP 404).
      # Raises Errors::BaseError or subclass if an HTTP error code received.
      def get(uid)
        self.class::MODEL.new(@connection.get("#{uid}").body)
      end

      # Public: Get the list of all objects that you have permission to see.
      #
      # Returns Array of objects as instances of the corresponding model.
      # Raises Errors::BaseError or subclass if an HTTP error code received.
      def list
        @connection.get('').body.map do |hash|
          self.class::MODEL.new(hash)
        end
      end

      # Public: Get the requirements for modifying an object.
      # This is most often used by the website to build a modification form.
      #
      # uid - The String with an object uid.
      #
      # Returns Models::ModifyRequirements the requirements.
      # Raises Errors::NotFound if the uid is not found (HTTP 404).
      # Raises Errors::BaseError or subclass if an HTTP error code received.
      def modify_requirements(uid)
        Models::ModifyRequirements.new(@connection.get("#{uid}/modify").body)
      end

      # Public: Modify an object using the provided options.
      # This is commonly used with accounts when utility login credentials need
      # to be updated, or with services when [de]activating the service.
      # By default, this will trigger all services related to this object
      # to update their bill and interval datasets.
      #
      # uid     - The String with an object uid.
      # options - The options object with a corresponding type
      #           (e.g. AccountOptions for accounts).
      #
      # Returns the modified object as an instance of the corresponding model.
      # Raises Errors::NotFound if the uid is not found (HTTP 404).
      # Raises Errors::BadRequest if the options are malformed (HTTP 400).
      # Raises Errors::BaseError or subclass if an HTTP error code received.
      def modify(uid, options)
        body = @connection.post("#{uid}/modify", options).body

        if body.count == 1
          # XXX: it is not documented in api
          self.class::MODEL.new(body.values.first)
        else
          self.class::MODEL.new(body)
        end
      end
    end
  end
end
