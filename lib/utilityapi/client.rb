#
# Copyright © 2015, TopCoder, Inc. All rights reserved.
#
# @author TCSASSEMBLER
# @version 0.1.0
#
require 'utilityapi/endpoints/accounts_api'
require 'utilityapi/endpoints/services_api'
require 'utilityapi/accounts_utilities'

module UtilityApi
  # Public: Client class incorporating all the individual API classes, so that
  # they can easily be instantiated with the same parameters.
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
  #
  # Attr_reader: accounts_utilities [AccountsUtilities] The created
  # AccountsUtilities instance.
  class Client
    attr_reader :base_url, :access_token, :retry_delay, :accounts, :services,
      :accounts_utilities

    # Public: Initialize a Client object.
    # Also instantiates AccountsApi, ServicesApi and
    # AccountsUtilities to allow easy access to them from one place.
    #
    # base_url     - The String with the base URL of the API.
    # access_token - The String with a generated API access token.
    # retry_delay  - The Float number of seconds to wait between tries.
    def initialize(access_token, base_url = BASE_URL, retry_delay = RETRY_DELAY)
      @base_url = base_url
      @access_token = access_token
      @retry_delay = retry_delay
      @accounts = Endpoints::AccountsApi.new(access_token, base_url)
      @services = Endpoints::ServicesApi.new(access_token, base_url)
      @accounts_utilities = AccountsUtilities.new(access_token, base_url, retry_delay)
    end
  end
end
