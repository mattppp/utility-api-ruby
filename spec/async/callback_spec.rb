#
# Copyright © 2015, TopCoder, Inc. All rights reserved.
#
# @author TCSASSEMBLER
# @version 0.1.0
#
require 'spec_helper'

describe 'Async operation with callback' do
  before(:all) { @accounts = UtilityApi::Endpoints::AccountsApi::new TOKEN  }

  before(:all) { @list_before = @accounts.list }
  after(:all) { expect(@accounts.list).to eq(@list_before) }

  describe 'works for all api classes' do
    it 'should support AccountsApi' do
      base = UtilityApi::Endpoints::AccountsApi.new TOKEN
      expect(base.async {}).
        to be_a(UtilityApi::AsyncHelper).and have_attributes(base: base)
    end

    it 'should support ServicesApi' do
      base = UtilityApi::Endpoints::ServicesApi.new TOKEN
      expect(base.async {}).
        to be_a(UtilityApi::AsyncHelper).and have_attributes(base: base)
    end

    it 'should support AccountsUtilities' do
      base = UtilityApi::AccountsUtilities.new TOKEN
      expect(base.async {}).
        to be_a(UtilityApi::AsyncHelper).and have_attributes(base: base)
    end
  end

  context 'normal operation' do
    context 'method with no arguments' do
      before(:all) do
        @expected = @accounts.list
      end

      it 'should get same result as the synchronous method' do
        callback = spy('callback')
        thread = @accounts.async {|res| callback.call(res)}.list
        expect(callback).not_to have_received(:call)
        thread.join
        expect(callback).to have_received(:call).with(@expected)
      end
    end

    context 'method with arguments' do
      before(:all) do
        @uid = @accounts.list[0].uid
        @expected = @accounts.get @uid
      end

      it 'should get same result as the synchronous method' do
        callback = spy('callback')
        thread = @accounts.async {|res| callback.call(res)}.get @uid
        expect(callback).not_to have_received(:call)
        thread.join
        expect(callback).to have_received(:call).with(@expected)
      end
    end

    context 'several methods in parallel' do
      it 'should get same result as the synchronous method' do
        expected = [@accounts.list, @accounts.add_requirements, @accounts.list]

        callback = spy('callback')
        threads = [
          @accounts.async { |res| callback.call(res) }.list,
          @accounts.async { |res| callback.call(res) }.add_requirements,
          @accounts.async { |res| callback.call(res) }.list
        ]
        expect(callback).not_to have_received(:call)
        threads.map { |t| t.join }
        expect(callback).
          to have_received(:call).
          with(eq(expected[0]).or eq(expected[1]).or eq(expected[2])).
          exactly(3).times
      end
    end
  end

  context 'error handling with errback' do
    it 'should correctly call errback' do
      callback = spy('callback')
      errback = spy('errback')
      thread = @accounts.
        async { |res| callback.call(res) }.
        onerror! { |e| errback.call(e) }.
        get 'nonexistent'

      expect{thread.join}.not_to raise_error
      expect(callback).not_to have_received(:call)
      expect(errback).to have_received(:call).with(UtilityApi::Errors::NotFound)
    end

    it 'should fail immediately if calling a nonexistent method' do
      expect{@accounts.async { raise }.onerror! { raise }.nonexistent}.
        to raise_error(NameError)
    end
  end

  context 'error handling without errback' do
    it 'should correctly raise error' do
      callback = spy('callback')
      thread = @accounts.async { |res| callback.call(res) }.get 'nonexistent'

      expect{thread.join}.to raise_error(UtilityApi::Errors::NotFound)
      expect(callback).not_to have_received(:call)
    end

    it 'should fail immediately if calling a nonexistent method' do
      expect{@accounts.async { raise }.nonexistent}.
        to raise_error(NameError)
    end
  end
end
