#
# Copyright © 2015, TopCoder, Inc. All rights reserved.
#
# @author TCSASSEMBLER
# @version 0.1.0
#
require 'utilityapi/endpoints/accounts_api'
require 'utilityapi/endpoints/services_api'
require 'utilityapi/model/service_options'
require 'utilityapi/asyncable'
require 'utilityapi/connection_errors'

module UtilityApi
  # Public: Various methods to work with accounts.
  # The methods call different endpoints APIs (not only AccountsApi), so they
  # cannot reside in AccountsApi.
  # Supports performing all the methods asynchronously.
  #
  # Attr_reader: base_url [String] The API base URL.
  #
  # Attr_reader: access_token [String] The API access token.
  #
  # Attr_reader: retry_delay [Float] The delay beween retries, in seconds.
  #
  # Attr_reader: accounts [AccountsApi] The created AccountsApi instance.
  #
  # Attr_reader: services [ServicesApi] The created ServicesApi instance.
  class AccountsUtilities
    include Asyncable

    attr_reader :base_url, :access_token, :retry_delay, :accounts, :services

    # Public: Initialize an AccountsUtilities object.
    # Also instantiates AccountsApi, ServicesApi as
    # they both are required for this class methods.
    #
    # base_url     - The String with the base URL of the API.
    # access_token - The String with a generated API access token.
    # retry_delay  - The Float number of seconds to wait between tries.
    def initialize(access_token, base_url = BASE_URL, retry_delay = RETRY_DELAY)
      @base_url = base_url
      @access_token = access_token
      @accounts = Endpoints::AccountsApi.new(access_token, base_url)
      @services = Endpoints::ServicesApi.new(access_token, base_url)
      @retry_delay = retry_delay
    end

    # Public: Create an account with the provided utility authorization
    # and access information, activate the service corresponding to it, and
    # get all the bills for this service.
    # Activating service means setting it active_until date in the future, which
    # is one year from now by default.
    # This method waits for the account and service to be completely created and
    # for the bills to be loaded, so it can take a while to return. Consider
    # calling asynchronously.
    #
    # options      - The account options as AccountOptions.
    # active_until - A Time object until which the service should be active.
    #                (default: nil, which corresponds to one year from now)
    #
    # Returns Hash {
    #   account: added account as Account,
    #   service: the service corresponding to this account as Service,
    #   bills: all the bills for this service as an Array of Bill
    # }
    # Raises Errors::BadRequest if the options are malformed (HTTP 400).
    # Raises Errors::BaseError or subclass if another HTTP error code received.
    def create_account(options, active_until = nil)
      added = accounts.add(options)

      begin
        sleep @retry_delay
        acc = accounts.get(added.uid)
      end while acc.latest.type == 'pending'

      unless acc.latest.type == 'updated'
        raise Errors::BaseError, "account type didn't become updated"
      end

      svcs = services.list_for_account(acc.uid)

      unless svcs.count == 1
        raise Errors::BaseError, "#{svcs.count} services for account, expected 1"
      end

      svc = svcs[0]

      if active_until.nil?
        active_until = Time.now + 1*365*24*3600
      end
      svc_options = Models::ServiceOptions.new(active_until: active_until)
      services.modify(svc.uid, svc_options)

      begin
        sleep @retry_delay
        svc = services.get(svc.uid)
      end while svc.latest.type == 'pending'

      unless svc.latest.type == 'updated'
        raise Errors::BaseError, "service type didn't become updated"
      end

      {
        account: acc,
        service: svc,
        bills: services.bills(svc.uid)
      }
    end
  end
end
