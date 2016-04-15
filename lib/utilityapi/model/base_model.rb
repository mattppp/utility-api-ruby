#
# Copyright © 2015, TopCoder, Inc. All rights reserved.
#
# @author TCSASSEMBLER
# @version 0.1.0
#
require 'time'
require 'json'

module UtilityApi
  module Models
    # Public: Base model mixin, provides methods common to all models.
    module BaseModel
      # Public: Initialize the model setting attributes from the Hash.
      #
      # attributes - The attributes of the model as a Hash.
      def initialize(attributes)
        attributes.each { |k, v| send "#{k}=", v }
      end

      # Public: Serialize the model object to a json String.
      # This omits nil attributes and converts Time to ISO8601 String format.
      #
      # opts - Hash of the json options, passed through to Hash.to_json.
      #
      # Returns String the json document.
      def to_json(opts = {})
        hash_processed = Hash[
          to_h.
            reject { |_, v| v.nil? }.
            map { |k, v| [k, v.is_a?(Time) ? v.iso8601 : v] }
        ]
        hash_processed.to_json(opts)
      end

      def notes=(opts = {})

      end
    end
  end
end
