#
# Copyright © 2015, TopCoder, Inc. All rights reserved.
#
# @author TCSASSEMBLER
# @version 0.1.0
#
module UtilityApi
  # Public: Mixin to support asynchronous execution of a class methods.
  # When included this adds async method which can be used to execute any other
  # method asynchronously.
  #
  # Examples
  #
  #   # assuming base is an instance of a class including this mixin
  #   # sequential execution of a method:
  #   value = base.get(uid)
  #   f(value) # process the value
  #
  #   # same method executed asynchronously, without callback:
  #   thread = base.async.get(uid)
  #   # ... other operations while the method is executed in the background ...
  #   value = thread.value # blocks until completed and raises errors, if any
  #   f(value)
  #
  #   # same method executed asynchronously, with callback:
  #   thread = base.async { |value| f(value) }.get(uid)
  #   # ... other operations while the method is executed in the background ...
  #   thread.join # blocks until completed and raises errors, if any
  #
  #   # using errback to handle errors:
  #   thread = base.async { |value| f(value) }.onerror! { |e| puts e }.get(uid)
  #   # ... other operations while the method is executed in the background ...
  #   thread.join # only blocks, no errors raised here
  module Asyncable
    # Public: Get an instance of AsyncHelper, which executes
    # any method of the base class in background.
    #
    # callback - Optional callback block, which will be called after a method
    #            is completed asynchronously.
    #
    # Returns AsyncHelper instance corresponding to this class.
    def async(&callback)
      AsyncHelper.new(self, &callback)
    end
  end

  # Public: Helper class to perform methods asynchronously.
  # This can be instantiated directly, but it's easier to call async on a class
  # which supports asynchronous execution (and includes Asyncable mixin).
  # See Asyncable for more information and examples.
  #
  # Attr: base [Object] The object which methods are to be run asynchronously.
  #
  # Attr: callback [Proc] The callback called after executing a method.
  #
  # Attr: errback [Proc] The callback called when an error occurs in a method.
  class AsyncHelper
    attr_reader :base, :callback, :errback

    # Internal: instantiate the helper given a base instance and a callback.
    #
    # base     - An instance of a base class with synchronous methods.
    # callback - Optional callback block, which will be called with the
    #            return value after a method has completed asynchronously.
    def initialize(base, &callback)
      @base = base
      @callback = callback
      @errback = nil
    end

    # Public: Add error handler which will be called in any error occurs in
    # a method called asynchronously.
    #
    # errback - A block which handles errors. It will be called with the error
    #           object if any error occurs.
    #
    # Returns AsyncHelper self to provide a fluent interface.
    def onerror!(&errback)
      @errback = errback
      self
    end

    # Public: Support calling any method on the helper that a base class
    # supports, but execute them asynchronously in a new Thread. This method
    # creates a new Thread, executes the base method there, then calls the
    # provided callbacks (if any) and sets the method return value as the Thread
    # value.
    #
    # See Asyncable for examples.
    #
    # sym   - Symbol specifying the method to call.
    # *args - The arguments for the base class method.
    #
    # Returns Thread the newly created thread.
    # Raises NameError immediately if the specified method was not found.
    def method_missing(sym, *args)
      method = @base.method(sym)
      Thread.new do
        begin
          res = method.call(*args)
        rescue => e
          if @errback.nil?
            raise
          else
            @errback.call(e)
          end
        else
          unless @callback.nil?
            @callback.call(res)
          end
          res
        end
      end
    end
  end
end
