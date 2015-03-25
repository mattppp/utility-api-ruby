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
    # Public: Model representing a meter interval. This object contains interval
    # data, including usage and demand. NOTE: Often, if a service tariff or
    # meter has been changed, the utility will no longer provide the interval
    # data before the change. We will try our best to collect all historical
    # interval data, but we are limited by what is made available by the
    # utility.
    #
    # Attr: service_uid [String] The unique identifier of the Service object to
    # which this interval object belongs. NOTE: There is no unique identifier
    # for individual intervals since they are only accessible with the service
    # uid.
    #
    # Attr: utility [String] The utility abbreviation. Will be one of "DEMO",
    # "PG&E", "SCE", or "SDG&E". This field is denormalized from the Account
    # object for convenience.
    #
    # Attr: utility_service_id [String] The utility's service identifier. This
    # field may be different from the parent Service's utility_service_id if the
    # service changed for the same location (e.g. if the customer switched
    # tariffs when they bought an electric vehicle or signed up for a demand
    # response program). We try to include past utility_service_ids so you can
    # have a more complete interval history for a utility service.
    #
    # Attr: utility_tariff_name [String] The interval's utility tariff (i.e.
    # rate schedule) for the service. This field may be different from different
    # from the parent Service's utility_tariff_name if the service tariff
    # changed for the same location (e.g. if the customer switched tariffs when
    # they bought an electric vehicle or signed up for a demand response
    # program). We try to include past utility_tariff_names so you can have a
    # more complete understanding of the customer's interval history.
    #
    # Attr: utility_service_address [String] The interval's service address for
    # the meter. This field may be different from different from the parent
    # Service's utility_service_address if the service address changed (e.g. if
    # the utility swapped out meters and updated the format of the service
    # address). We try to include past utility_service_addresss so you can have
    # a more complete understanding of the interval history for the same
    # service.
    #
    # Attr: utility_meter_number [String] The interval's meter number for the
    # service. This field may be different from different from the parent
    # Service's utility_meter_number if the meter changed (e.g. if the utility
    # swapped out an analog meter for a smart meter). We try to include past
    # utility_meter_numbers so you can have a more complete understanding of the
    # interval history for the same service.
    #
    # Attr: interval_start [Time] The start timestamp of the interval period.
    #
    # Attr: interval_end [Time] The end timestamp of the interval period.
    #
    # Attr: interval_kWh [Float] The total energy usage (in kilowatt hours)
    # during the interval period.
    #
    # Attr: interval_kW [Float] The total demand (in kilowatts) during the
    # interval period. This is a simple calculation of the usage divided by the
    # time period. NOTE: For demand charges, the demand interval period might be
    # shorter than what is provided in these intervals (i.e. if the demand is
    # calculated for a 15 interval, but we can only collect hour intervals), so
    # you may not be able to confirm the demand charge on the bill just from
    # this interval data :(
    #
    # Attr: source [String] The location where the interval data was collected.
    # If the source is available for download (e.g. a zip file), a link is
    # provided here. If the source is not available for download (e.g. data
    # collected from the utility's web portal), this field is left blank.
    #
    # Attr: updated [Time] When the interval data was last updated.
    class Interval < Struct.new(:service_uid, :utility,
      :utility_service_id, :utility_tariff_name, :utility_service_address,
      :utility_meter_number, :interval_kWh, :interval_kW, :source,
      :interval_start, :interval_end, :updated)
      include BaseModel

      # Public: Set the value as Time, converted from an ISO8601 String.
      #
      # value - The String ISO8601 value.
      #
      # Returns the value as Time.
      def interval_start=(value)
        super Time.iso8601(value)
      end

      # Public: Set the value as Time, converted from an ISO8601 String.
      #
      # value - The String ISO8601 value.
      #
      # Returns the value as Time.
      def interval_end=(value)
        super Time.iso8601(value)
      end

      # Public: Set the value as Time, converted from an ISO8601 String.
      #
      # value - The String ISO8601 value.
      #
      # Returns the value as Time.
      def updated=(value)
        super Time.iso8601(value)
      end
    end
  end
end
