#
# Copyright © 2015, TopCoder, Inc. All rights reserved.
#
# @author TCSASSEMBLER
# @version 0.1.0
#
require 'utilityapi/model/account'
require 'utilityapi/model/add_modify_requirements'
require 'utilityapi/model/account_options'
require 'utilityapi/endpoints/base_endpoint'

module UtilityApi
  module Endpoints
    # Public: API methods for working with accounts objects.
    # This inherits from BaseEndpoint and so has also all its methods.
    # Supports performing all the methods asynchronously.
    class AccountsApi < BaseEndpoint
      # Public: String with the URL of this endpoint relative to base API URL.
      ENDPOINT_URL = 'accounts'

      # Public: Class of the corresponding object model.
      MODEL = Models::Account

      # Public: Get the requirements for adding an account.
      # This is most often used by the website to build the account adding form.
      #
      # Returns Models::AddRequirements the requirements.
      # Raises Errors::BaseError or subclass if an HTTP error code received.
      def add_requirements
        Models::AddRequirements.new(@connection.get('add').body)
      end

      # Public: Add an account with the provided utility authorization
      # and access information.
      #
      # options - The options as AccountOptions.
      #
      # Returns Models::Account the added account.
      # Raises Errors::BadRequest if the options are malformed (HTTP 400).
      # Raises Errors::BaseError or subclass if an HTTP error code received.
      def add(options)
        self.class::MODEL.new(@connection.post('add', options).body)
      end

      # Public: Get the account authorization file. This file is a zip archive
      # and is present only if this account has indirect authorization.
      #
      # uid - The String with an account uid.
      #
      # Returns String the zip file content.
      # Raises Errors::NotFound if the file is not found (HTTP 404).
      # Raises Errors::BaseError or subclass if an HTTP error code received.
      def auth_file(uid)
        @connection.get("#{uid}/auth.zip").body
      end

      # Public: Get a server-signed confirmation code for deleting an account.
      # It is required for deletion and must be passed to the delete method. It
      # is present mostly to prevent you from accidentally deleting an object.
      #
      # uid - The String with an account uid.
      #
      # Returns String the deletion code.
      # Raises Errors::NotFound if the uid is not found (HTTP 404).
      # Raises Errors::BaseError or subclass if an HTTP error code received.
      def delete_code(uid)
        @connection.get("#{uid}/delete").body['code']
      end

      # Public: Delete an account. Note: this is a cascade event! All services
      # that belong to that account will also be deleted, and all bills and
      # intervals that belong those services will also be deleted! This request
      # requires a signed confirmation code obtained by delete_code.
      #
      # uid  - The String with an account uid.
      # code - The String with the deletion code returned from delete_code.
      #
      # Returns Hash with keys 'success' (true/false) and 'account_uid'.
      # Raises Errors::NotFound if the uid is not found (HTTP 404).
      # Raises Errors::BadRequest if the code is invalid (HTTP 400).
      # Raises Errors::BaseError or subclass if an HTTP error code received.
      def delete(uid, code)
        @connection.post("#{uid}/delete", {code: code}).body
      end
    end
  end
end
