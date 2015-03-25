#
# Copyright © 2015, TopCoder, Inc. All rights reserved.
#
# @author TCSASSEMBLER
# @version 0.1.0
#
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'simplecov'

# SimpleCov should be started before requiring the code under test
SimpleCov.start do
  add_filter '/spec/'
end

require 'factory_girl'
require 'utilityapi'
require_relative 'factories'

RSpec.configure do |config|
  # make FactoryGirl methods available in tests
  config.include FactoryGirl::Syntax::Methods
  # lint all the factories
  config.before(:suite) do
    FactoryGirl.lint
  end
end

TOKEN = 'b06c07a9bf3a464a88f6b2d5ea705f88'

# negated matchers for cleaner testing
RSpec::Matchers.define_negated_matcher :be_non_empty, :be_empty
RSpec::Matchers.define_negated_matcher :be_dead, :be_alive

# matcher checking if object has no nil/empty fields on any nesting level
RSpec::Matchers.define :be_non_empty_recursive do
  # Internal: Helper method to get all the nil/empty fields of the object.
  #
  # k   - String with key (field name) of the current object, should be '' for
  #       the provided object itself.
  # obj - Object to find empty fields of.
  #
  # Returns Array<String>, with the names of nil/empty fields of the provided
  # object. Nested field names are separated with dots, '[]' means an Array
  # element.
  def empty_fields_recursive(k = '', obj)
    case obj
    when nil
      [k]
    when Struct, Hash
      obj.to_h.
        flat_map { |k, v| empty_fields_recursive(k, v) }.
        map { |e| "#{k}.#{e}" }
    when Array
      obj.flat_map { |v| empty_fields_recursive('[]', v) }
    when String
      obj.empty? ? [k] : []
    when Numeric, Time, Range, TrueClass, FalseClass
      []
    else
      ["#{k} - unsupported"]
    end
  end

  match do |obj|
    obj = obj.to_h
    empty_fields_recursive(obj).empty?
  end

  failure_message do |obj|
    "expected #{obj} to have nothing empty, but: #{empty_fields_recursive(obj)}"
  end
end
