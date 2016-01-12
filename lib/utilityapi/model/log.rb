#
# Copyright © 2015, TopCoder, Inc. All rights reserved.
#
# @author TCSASSEMBLER
# @version 0.1.0
#
require 'time'
require 'utilityapi/model/base_model'

module UtilityApi
  module Models
    # Public: Model representing a log entry. These are used as values for
    # modified and latest logs on several other objects, as well as in list form
    # for token usage histories.
    #
    # Attr: type [String] The log entry type. One of "updated", "error", or
    # "pending". Updated logs indicate a successfully finished task.
    # Errors::BaseError logs indicate a task that finished with an error.
    # Pending logs indicate that a task is still ongoing.
    #
    # Attr: timestamp [Time] The timestamp of the log entry.
    #
    # Attr: message [String] The message of the log entry. These may change, so
    # don't rely on their syntax.
    class Log < Struct.new(:type, :message, :timestamp, :code)
      include BaseModel

      # Public: Initialize the Log object. The only thing different from the
      # BaseModel constructor is assigning 'type' to '!nil!' if it is not
      # present. This is done because the website API in some cases doesn't
      # return this field, but it is listed as a required one.
      def initialize(hash)
        # XXX: docs say that type is required, but sometimes it is not returned
        hash['type'] ||= '!nil!'
        super
      end

      # Public: Set the value as Time, converted from an ISO8601 String.
      #
      # value - The String ISO8601 value.
      #
      # Returns the value as Time.
      def timestamp=(value)
        super Time.iso8601(value)
      end
    end
  end
end
