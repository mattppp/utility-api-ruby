#
# Copyright © 2015, TopCoder, Inc. All rights reserved.
#
# @author TCSASSEMBLER
# @version 0.1.0
#
require 'faraday'

module UtilityApi
  # Internal: Faraday middleware to wrap HTTP errors into Errors::BaseError
  # subclasses for easier rescuing from them.
  class ConnectionErrorsHandler < Faraday::Response::Middleware
    # Internal: Raises the appropriate Errors::BaseError subclass depending
    # on the HTTP status code returned. When the code represents no error,
    # does nothing.
    # This method is called by Faraday when processing requests.
    #
    # env - Faraday response environment.
    #
    # Returns nothing.
    # Raises appropriate Errors::BaseError subclass, or nothing.
    def on_complete(env)
      case env[:status]
      when 400
        raise Errors::BadRequest
      when 404
        raise Errors::NotFound
      when 500
        raise Errors::InternalServerError
      when 400..600
        raise Errors::BaseError, "HTTP code: #{env[:status]}"
      else
        # do nothing, as the status code represents successful response
      end
    end
  end

  module Errors
    # Public: Custom error class for rescuing from all UtilityApi errors.
    # Raised when no specific subclass suits the error better.
    class BaseError < StandardError; end

    # Public: Custom error class, raised when the HTTP status code 400 received.
    class BadRequest < BaseError; end

    # Public: Custom error class, raised when the HTTP status code 404 received.
    class NotFound < BaseError; end

    # Public: Custom error class, raised when the HTTP status code 500 received.
    class InternalServerError < BaseError; end
  end
end
