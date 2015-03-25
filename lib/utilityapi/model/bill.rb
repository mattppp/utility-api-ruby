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
    # Public: Model representing a utility bill. This object contains bill data,
    # including usage and pricing.
    #
    # Attr: service_uid [String] The unique identifier of the Service object to
    # which this bill object belongs. NOTE: There is no unique identifier for
    # individual bills since they are only accessible with the service uid.
    #
    # Attr: utility [String] The utility abbreviation. Will be one of "DEMO",
    # "PG&E", "SCE", or "SDG&E". This field is denormalized from the Account
    # object for convenience.
    #
    # Attr: utility_service_id [String] The utility's service identifier. This
    # field may be different from different from the parent Service's
    # utility_service_id if the service changed for the same location (e.g. if
    # the customer switched tariffs when they bought an electric vehicle or
    # signed up for a demand response program). We try to include past
    # utility_service_ids so you can have a more complete bill history for a
    # utility service.
    #
    # Attr: utility_tariff_name [String] The bill's utility tariff (i.e. rate
    # schedule) for the service. This field may be different from different from
    # the parent Service's utility_tariff_name if the service tariff changed for
    # the same location (e.g. if the customer switched tariffs when they bought
    # an electric vehicle or signed up for a demand response program). We try to
    # include past utility_tariff_names so you can have a more complete
    # understanding of the customer's billing history and usage.
    #
    # Attr: utility_service_address [String] The bill's service address for the
    # meter. This field may be different from different from the parent
    # Service's utility_service_address if the service address changed (e.g. if
    # the utility swapped out meters and updated the format of the service
    # address). We try to include past utility_service_addresss so you can have
    # a more complete understanding of the bill history for the same service.
    #
    # Attr: utility_meter_number [String] The bill's meter number for the
    # service. This field may be different from different from the parent
    # Service's utility_meter_number if the meter changed (e.g. if the utility
    # swapped out an analog meter for a smart meter). We try to include past
    # utility_meter_numbers so you can have a more complete understanding of the
    # bill history for the same service.
    #
    # Attr: bill_start_date [Time] The start date of the billing period for the
    # service.
    #
    # Attr: bill_end_date [Time] The end date of the billing period for the
    # service.
    #
    # Attr: bill_bill_days [Integer] The total number of days between the start
    # and end dates of the billing period for the service.
    #
    # Attr: bill_statement_date [Time] The date that the bill stated was issued.
    #
    # Attr: bill_total_kWh [Float] The total energy usage (in kilowatt hours)
    # during the billing period for the service.
    #
    # Attr: bill_total [Float] The bill charges (in dollars) for electricity
    # usage during the billing period.
    #
    # Attr: bill_breakdown [Array<BillCharge>] A breakdown of the individual
    # charges contributing to the bill_total amount.
    #
    # Attr: source [String] The location where the bill data was collected. If
    # the source is available for download (e.g. a pdf bill), a link is provided
    # here. If the source is not available for download (e.g. data collected
    # from the utility's web portal), this field is left blank.
    #
    # Attr: updated [Time] When the bill data was last updated.
    class Bill < Struct.new(:service_uid, :utility, :utility_service_id,
      :utility_tariff_name, :utility_service_address, :utility_meter_number,
      :bill_bill_days, :bill_total_kWh, :bill_total, :source, :bill_start_date,
      :bill_end_date, :bill_statement_date, :updated, :bill_breakdown)
      include BaseModel

      # Public: Set the value as Time, converted from an ISO8601 String.
      #
      # value - The String ISO8601 value.
      #
      # Returns the value as Time.
      def bill_start_date=(value)
        super Time.iso8601(value)
      end

      # Public: Set the value as Time, converted from an ISO8601 String.
      #
      # value - The String ISO8601 value.
      #
      # Returns the value as Time.
      def bill_end_date=(value)
        super Time.iso8601(value)
      end

      # Public: Set the value as Time, converted from an ISO8601 String.
      #
      # value - The String ISO8601 value.
      #
      # Returns the value as Time.
      def bill_statement_date=(value)
        super Time.iso8601(value)
      end

      # Public: Set the value as an Array of BillCharge, converted from an Hash.
      #
      # value - The Hash value.
      #
      # Returns the value as an Array of BillCharge.
      def bill_breakdown=(value)
        super(value.map { |k, v| BillCharge.new(name: k, amount: v) })
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

    # Public: Model representing an individual charge in a bill.
    #
    # Attr: name [String] The charge name.
    #
    # Attr: amount [Float] The charge amount in USD.
    class BillCharge < Struct.new(:name, :amount)
      include BaseModel
    end
  end
end
