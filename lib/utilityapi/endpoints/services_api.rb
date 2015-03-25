#
# Copyright © 2015, TopCoder, Inc. All rights reserved.
#
# @author TCSASSEMBLER
# @version 0.1.0
#
require 'utilityapi/model/service'
require 'utilityapi/model/bill'
require 'utilityapi/model/interval'
require 'utilityapi/model/service_options'
require 'utilityapi/endpoints/base_endpoint'

module UtilityApi
  module Endpoints
    # Public: API methods for working with services objects.
    # This inherits from BaseEndpoint and so has also all its methods.
    # Supports performing all the methods asynchronously.
    class ServicesApi < BaseEndpoint
      # Public: String with the URL of this endpoint relative to base API URL.
      ENDPOINT_URL = 'services'

      # Public: Class of the corresponding object model.
      MODEL = Models::Service

      # Public: Get a list of bills for a service.
      #
      # uid - The String with a service uid.
      #
      # Returns Array<Models::Bill> the bills.
      # Raises Errors::NotFound if the uid is not found (HTTP 404).
      # Raises Errors::BaseError or subclass if an HTTP error code received.
      def bills(uid)
        @connection.get("#{uid}/bills").body.map do |hash|
          Models::Bill.new(hash)
        end
      end

      # Public: Get the raw bills for a service as a zip archive.
      #
      # uid - The String with a service uid.
      #
      # Returns String the zip file content.
      # Raises Errors::NotFound if the uid is not found (HTTP 404).
      # Raises Errors::BaseError or subclass if an HTTP error code received.
      def bills_archive(uid)
        @connection.get("#{uid}/bills.zip").body
      end

      # Public: Get a specific raw bill for a service.
      #
      # uid      - The String with a service uid.
      # filename - The String with a bill filename.
      #
      # Returns String - the bill file content.
      # Raises Errors::NotFound if the uid or filename is not found (HTTP 404).
      # Raises Errors::BaseError or subclass if an HTTP error code received.
      def bill_raw(uid, filename)
        @connection.get("#{uid}/bills/#{filename}").body
      end

      # Public: Get a list of intervals for a service.
      #
      # uid - The String with a service uid.
      #
      # Returns Array<Models::Interval> the intervals.
      # Raises Errors::NotFound if the uid is not found (HTTP 404).
      # Raises Errors::BaseError or subclass if an HTTP error code received.
      def intervals(uid)
        @connection.get("#{uid}/intervals").body.map do |hash|
          Models::Interval.new(hash)
        end
      end

      # Public: Get the list of services corresponding to an account.
      #
      # account_uid - The String with an account uid.
      #
      # Returns Array<Models::Service> the corresponding services.
      # Raises Errors::InternalServerError if the uid is not found (HTTP 500).
      # XXX: api returns HTTP 500 when not found, but should 404
      # Raises Errors::BaseError or subclass if an HTTP error code received.
      def list_for_account(account_uid)
        @connection.get('', accounts: account_uid).body.map do |hash|
          self.class::MODEL.new(hash)
        end
      end

      # Public: Get a server-signed confirmation code for reseting a service.
      # This code is required for reseting and must be passed to the reset
      # method. It is present mostly to prevent you from accidentally reseting a
      # service.
      #
      # uid - String a service uid.
      #
      # Returns the reset code as a String.
      # Raises Errors::NotFound if the uid is not found (HTTP 404).
      # Raises Errors::BaseError or subclass if an HTTP error code received.
      def reset_code(uid)
        @connection.get("#{uid}/reset").body['code']
      end

      # Public: Reset a service.
      # The active_until date will be changed to the current date (i.e.
      # deactivated) and all bill and interval data will be deleted.
      # This request requires a signed confirmation code obtained by reset_code.
      #
      # uid  - The String with a service uid.
      # code - The String with the deletion code returned from delete_code.
      #
      # Returns Hash with keys 'success' (true/false) and 'service_uid'.
      # Raises Errors::NotFound if the uid is not found (HTTP 404).
      # Raises Errors::BadRequest if the code is invalid (HTTP 400).
      # Raises Errors::BaseError or subclass if an HTTP error code received.
      def reset(uid, code)
        @connection.post("#{uid}/reset", {code: code}).body
      end
    end
  end
end
