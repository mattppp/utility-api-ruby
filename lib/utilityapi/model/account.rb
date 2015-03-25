#
# Copyright © 2015, TopCoder, Inc. All rights reserved.
#
# @author TCSASSEMBLER
# @version 0.1.0
#
require 'time'
require 'utilityapi/model/base_model'
require 'utilityapi/model/log'

module UtilityApi
  module Models
    # Public: Model representing a utility account. It contains the customer
    # authorization and access credentials for the utility account.
    #
    # Attr: uid [String] The unique identifier of the object. Account uids are
    # mostly integers, but they are not guaranteed to stay that way, so you
    # should treat them as strings.
    #
    # Attr: user_uid [String] The unique identifier of the User that created the
    # Account. User uids are mostly integers, but they are not guaranteed to
    # stay that way, so you should treat them as strings.
    #
    # Attr: utility [String] The utility abbreviation. Will be one of "DEMO",
    # "PG&E", "SCE", or "SDG&E".
    #
    # Attr: created [Time] A timestamp from when the object was created.
    #
    # Attr: auth_type [String] The type of authorization submitted. Can be
    # either "owner" or "3rdparty".
    #
    # Attr: auth [String] Details about the authorizer. If the auth_type is
    # "owner", then this field is the customer signature giving UtilityAPI
    # authorization to access their utility account on their behalf. If the
    # auth_type is "3rdparty", then this field is a link to the submitted 3rd
    # party customer authorization form giving 3rd party authorization to access
    # the utility account. NOTE: Always check the auth_type before using the
    # link in this field. A malicious person could have put in a bogus link as
    # their real name, so don't just check this field to see if it starts with
    # http. If you are stubborn and insist on not checking the auth_type field,
    # at least make sure you test that this field starts with
    # "https://utilityapi.com/" before making it a link.
    #
    # Attr: auth_expires [Time] A timestamp from when the customer authorization
    # expires.
    #
    # Attr: login [String] The type of access to that is used to collect the
    # data. So far, this can be "credentials" or "account_number", but in the
    # future we may add more access methods (for example, Green Button Connect).
    #
    # Attr: latest [Log] The latest log message for service access of the
    # account. This is what you check to see if the Account is currently looking
    # for Services (i.e. "pending"), has finished (i.e. "updated"), or raised an
    # error (i.e. "error"). See the examples to see what these can look like.
    #
    # Attr: modified [Log] The latest log message for modifying the account.
    # This is what you check to see when an Account modification last took place
    # (changing credentials, expiring authorization, etc.).
    class Account < Struct.new(:uid, :user_uid, :utility, :auth_type, :auth,
      :login, :created, :auth_expires, :latest, :modified)
      include BaseModel

      # Public: Set the value as Time, converted from an ISO8601 String.
      #
      # value - The String ISO8601 value.
      #
      # Returns the value as Time.
      def auth_expires=(value)
        super Time.iso8601(value)
      end

      # Public: Set the value as Time, converted from an ISO8601 String.
      #
      # value - The String ISO8601 value.
      #
      # Returns the value as Time.
      def created=(value)
        super Time.iso8601(value)
      end

      # Public: Set the value as Log, converted from a Hash object.
      #
      # value - The Hash value.
      #
      # Returns the value as Log.
      def latest=(value)
        super Log.new(value)
      end

      # Public: Set the value as Log, converted from a Hash object.
      #
      # value - The Hash value.
      #
      # Returns the value as Log.
      def modified=(value)
        super Log.new(value)
      end
    end
  end
end
