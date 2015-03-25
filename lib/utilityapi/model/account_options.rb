#
# Copyright © 2015, TopCoder, Inc. All rights reserved.
#
# @author TCSASSEMBLER
# @version 0.1.0
#
require 'utilityapi/model/base_model'

module UtilityApi
  module Models
    # Public: Model representing options for adding a new account or modifying
    # an existing one.
    #
    # Attr: utility [String] One of the utilities that are listed in
    # requirements. The current options are "DEMO", "PG&E", "SCE", and "SDG&E".
    # This is required for all add requests.
    #
    # Attr: auth_type [String] The type of customer customer authorization. Can
    # be either "owner" or "3rdparty". This is required for all add requests.
    #
    # Attr: real_name [String] The full name of the customer giving direct
    # authorization. This is the digital signature of the owner of the utility
    # account. If the auth-type is "owner", this field is required.
    #
    # Attr: third_party_file [String] A base64 encoded string of a completed
    # utility authorization form filled out and signed by the owner of the
    # utility account. If the auth-type is "3rdparty", this field is required.
    #
    # Attr: utility_username [String] The login username of the utility account
    # that the customer is authorizing access to. This is one of the fields that
    # is in the access options.
    #
    # Attr: utility_password [String] The login password of the utility account
    # that the customer is authorizing access to. This is one of the fields that
    # is in the access options.
    class AccountOptions < Struct.new(:utility, :auth_type, :real_name,
        :'3rdparty_file', :utility_username, :utility_password)
      include BaseModel

      alias_method :third_party_file, :'3rdparty_file'
      alias_method :third_party_file=, :'3rdparty_file='
    end
  end
end
