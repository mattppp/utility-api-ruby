#
# Copyright © 2015, TopCoder, Inc. All rights reserved.
#
# @author TCSASSEMBLER
# @version 0.1.0
#
require 'utilityapi/model/base_model'

module UtilityApi
  module Models
    # Public: Model representing options for modifying a service.
    #
    # Attr: active_until [Time, String] If the time is in the past, the service
    # is considered inactive and data will not be collected. If the time is in
    # the future, data will be collected periodicaly until that time. If it has
    # a value of 'now', the time will be set to the current time and the data
    # will be collected only once.
    #
    # Attr: update_data [Boolean] By default, when you modify as service, we
    # will automatically re-collect the service data if the active_until time is
    # in the future. If you don't want this to happen, set update_data to false.
    class ServiceOptions < Struct.new(:active_until, :update_data)
      include BaseModel
    end
  end
end
