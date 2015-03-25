#
# Copyright © 2015, TopCoder, Inc. All rights reserved.
#
# @author TCSASSEMBLER
# @version 0.1.0
#
require 'utilityapi/model/base_model'
require 'utilityapi/model/account'
require 'utilityapi/model/service'

module UtilityApi
  module Models
    # Public: Model representing requirements to add a new object.
    #
    # Attr: help [String] Help text.
    #
    # Attr: docs [String] URL to the documentation.
    #
    # Attr: options [Array<AddModifyUtility, AddModifyOption>] Available options
    # and utilities.
    class AddRequirements < Struct.new(:help, :docs, :options)
      include BaseModel

      # Public: Set the value as an Array of AddModifyUtility and
      # AddModifyOption, converted from an Array of Hash.
      #
      # value - The value as an Array of Hash.
      #
      # Returns the value as an Array of AddModifyUtility and AddModifyOption.
      def options=(value)
        super(value.map do |option|
          if option.key?('utility')
            AddModifyUtility.new(option)
          else
            AddModifyOption.new(option)
          end
        end)
      end
    end

    # Public: Model representing requirements to modify an object
    # (includes the object itself)
    #
    # Attr: object [Account, Service] The object which is to be modified.
    #
    # Attr: help [String] Help text.
    #
    # Attr: docs [String] URL to the documentation.
    #
    # Attr: options [Array<AddModifyUtility, AddModifyOption>] Available options
    # and utilities.
    class ModifyRequirements < Struct.new(:object, :help, :docs, :options)
      include BaseModel

      # Public: Set the object attribute to the Account created from the Hash.
      #
      # value - The account as a Hash.
      #
      # Returns the object value as an Account.
      def account=(value)
        self.object = Account.new(value)
      end

      # Public: Set the object attribute to the Service created from the Hash.
      #
      # value - The service as a Hash.
      #
      # Returns the object value as an Service.
      def service=(value)
        self.object = Service.new(value)
      end

      # Public: Set the value as an Array of AddModifyUtility and
      # AddModifyOption, converted from an Array of Hash.
      #
      # value - The value as an Array of Hash.
      #
      # Returns the value as an Array of AddModifyUtility and AddModifyOption.
      def options=(value)
        super(value.map do |option|
          if option.key?('utility')
            AddModifyUtility.new(option)
          else
            AddModifyOption.new(option)
          end
        end)
      end
    end

    # Public: Model representing an option in adding or modification
    # requirements.
    #
    # Attr: name [String] The option name.
    #
    # Attr: value [String] The description of the option value type.
    #
    # Attr: required [Boolean] Whether the option is required.
    #
    # Attr: description [String] The option description.
    class AddModifyOption < Struct.new(:name, :value, :required, :description)
      include BaseModel
    end

    # Public: Model representing a utility in adding or modification
    # requirements.
    #
    # Attr: utility [String] The utility short name (identifier).
    #
    # Attr: name [String] The utility full name.
    #
    # Attr: allows [Array<String>] The allowed authorization types for the
    # utility.
    #
    # Attr: options [Array<AddModifyUtilityOption>] Available utility options.
    class AddModifyUtility < Struct.new(:utility, :name, :allows, :options)
      include BaseModel

      # Public: Set the value as an Array of AddModifyUtilityOption, converted
      # from an Array of Hash.
      #
      # value - The value as an Array of Hash.
      #
      # Returns the value as an Array of AddModifyUtilityOption.
      def options=(value)
        super(value.flatten.map do |option|
          AddModifyUtilityOption.new(option)
        end)
      end
    end

    # Public: Model representing an option for a utility in adding or
    # modification requirements.
    #
    # Attr: name [String] The option name.
    #
    # Attr: type [String] The option type.
    #
    # Attr: help [String] The option help text.
    class AddModifyUtilityOption < Struct.new(:name, :type, :help)
      include BaseModel
    end
  end
end
