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
    # Public: Model representing a a utility service. This object contains
    # metadata on the service such as meter number, tariff, etc.
    #
    # Attr: uid [String] The unique identifier of the object. Service uids are
    # mostly integers, but they are not guaranteed to stay that way, so you
    # should treat them as strings. NOTE: This is specific to UtilityAPI, not
    # the utility. The utility's identifier for a service is found in the
    # utility_service_id field.
    #
    # Attr: user_uid [String] The unique identifier of the User that created the
    # Account to which this Service belongs. If you request the Account object,
    # the user_uid field in that object will be the same as this value.
    #
    # Attr: account_uid [String] The unique identifier of the Account object to
    # which this Service belongs.
    #
    # Attr: account_auth_type [String] The type of authorization submitted. Can
    # be either "owner" or "3rdparty". This is the same field as the Account
    # auth_type field.
    #
    # Attr: account_auth [String] Details about the authorizer. This contains
    # either a customer signature giving UtilityAPI authorization to access
    # their utility account on their behalf, or a link to the submitted 3rd
    # party customer authorization form giving 3rd party authorization to access
    # the utility account. This is the same field as the Account auth field.
    #
    # Attr: utility [String] The utility abbreviation. Will be one of "DEMO",
    # "PG&E", "SCE", or "SDG&E". This field is denormalized from the Account
    # object for convenience.
    #
    # Attr: created [Time] A timestamp from when the object was created.
    #
    # Attr: active_until [Time] A timestamp for when to stop monitoring this
    # service for updates. This cannot be set to a date/time after the parent
    # Account auth_expires value.
    #
    # Attr: latest [Log] The latest log message for data collection of the
    # service. This is what you check to see if the Service is currently looking
    # for bills and intervals (i.e. "pending"), has finished (i.e. "updated"),
    # or raised an error (i.e. "error"). See the examples to see what these can
    # look like.
    #
    # Attr: modified [Log] The latest log message for modifying the service.
    # This is what you check to see when an Service modification last took place
    # (usually changing active_until, etc.).
    #
    # Attr: utility_service_id [String] The utility's service identifier. The
    # format of this is different for each utility (may contain dashes, spaces,
    # etc.).
    #
    # Attr: utility_tariff_name [String] The current utility tariff (i.e. rate
    # schedule) for the service. May not be included if Account is still looking
    # up Services
    #
    # Attr: utility_service_address [String] The service address for the
    # service. This is what the utility uses and may not be an address you can
    # use to search for the address on an online map. We may add another field
    # with a mappable address at some point in the future, so please let us if
    # that would be valuable to you. May not be included if Account is still
    # looking up Services
    #
    # Attr: utility_billing_account [String] The billing account id for the
    # service. This may or may not be different from the utility_service_id. The
    # format of this is different for each utility (may contain dashes, spaces,
    # etc.). May not be included if Account is still looking up Services
    #
    # Attr: utility_billing_contact [String] The billing contact name for the
    # service. The format of this is different for each utility (may contain
    # dashes, spaces, etc.). May not be included if Account is still looking up
    # Services
    #
    # Attr: utility_billing_address [String] The billing address for the service
    # (i.e. where the bills are sent). May not be included if Account is still
    # looking up Services
    #
    # Attr: utility_meter_number [String] The current meter number for the
    # physical meter on the service. Some utilities may use the same number for
    # both the utility_service_id and the utility_meter_number, but many
    # utilities have different numbers for these fields (which is why we list
    # them separately). May not be included if Account is still looking up
    # Services
    #
    # Attr: bill_coverage [Array<Range<Time>>] A list of date ranges that are
    # covered by collected bills. If we have a complete history of bills, there
    # will be only one date range in this array. If there is are some missing
    # bills, the date ranges will only show the coverage that is covered by the
    # collected bills. If no bills have been collected, this array will be
    # empty. This field can be useful in checking to see if the Service meets
    # your coverage requirements.
    #
    # Attr: bill_count [Integer] The number of bills that have been collected
    # and parsed. This number should match the length of the list returned by
    # the bills method.
    #
    # Attr: interval_coverage [Array<Range<Time>>] A list of date ranges that
    # are covered by collected intervals. If we have a complete history of
    # intervals, there will be only one date range in this array. If there is
    # are some missing intervals, the date ranges will only show the coverage
    # that is covered by the collected intervals. If no intervals have been
    # collected, this array will be empty. This field can be useful in checking
    # to see if the Service meets your coverage requirements.
    #
    # Attr: interval_count [Integer] The number of intervals that have been
    # collected and parsed. This number should match the length of the list
    # returned by the intervals method.
    class Service < Struct.new(:uid, :user_uid, :account_uid,
      :account_auth_type, :account_auth, :utility, :utility_service_id,
      :utility_tariff_name, :utility_service_address, :utility_billing_account,
      :utility_billing_contact, :utility_billing_address, :utility_meter_number,
      :bill_count, :interval_count, :created, :active_until, :latest,
      :bill_coverage, :interval_coverage, :service_class,
      :bill_sources, # XXX: this is not documented in the API
      #:modified # XXX: this is listed in docs, but not returned
      )
      include BaseModel

      # Public: Set the value as Time, converted from an ISO8601 String.
      #
      # value - The String ISO8601 value.
      #
      # Returns the value as Time.
      def active_until=(value)
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

      # Public: Set the value as an Array of Time Ranges, converted from an
      # Array of ISO8601 Strings.
      #
      # value - The value as an Array of ISO8601 Strings.
      #
      # Returns the value as an Array of Time Ranges.
      def bill_coverage=(value)
        super(value.map { |from, to| Time.iso8601(from)..Time.iso8601(to) })
      end

      # Public: Set the value as an Array of Time Ranges, converted from an
      # Array of ISO8601 Strings.
      #
      # value - The value as an Array of ISO8601 Strings.
      #
      # Returns the value as an Array of Time Ranges.
      def interval_coverage=(value)
        super(value.map { |from, to| Time.iso8601(from)..Time.iso8601(to) })
      end
    end
  end
end
