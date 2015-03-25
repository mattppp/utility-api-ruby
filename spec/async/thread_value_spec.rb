#
# Copyright © 2015, TopCoder, Inc. All rights reserved.
#
# @author TCSASSEMBLER
# @version 0.1.0
#
require 'spec_helper'

describe 'Async operation with thread value' do
  before(:all) { @accounts = UtilityApi::Endpoints::AccountsApi.new TOKEN  }

  before(:all) { @list_before = @accounts.list }
  after(:all) { expect(@accounts.list).to eq(@list_before) }

  describe 'works for all api classes' do
    it 'should support AccountsApi' do
      base = UtilityApi::Endpoints::AccountsApi.new TOKEN
      expect(base.async).
        to be_a(UtilityApi::AsyncHelper).and have_attributes(base: base)
    end

    it 'should support ServicesApi' do
      base = UtilityApi::Endpoints::ServicesApi.new TOKEN
      expect(base.async).
        to be_a(UtilityApi::AsyncHelper).and have_attributes(base: base)
    end

    it 'should support AccountsUtilities' do
      base = UtilityApi::AccountsUtilities.new TOKEN
      expect(base.async).
        to be_a(UtilityApi::AsyncHelper).and have_attributes(base: base)
    end
  end

  context 'normal operation' do
    context 'method with no arguments' do
      before(:all) do
        @expected = @accounts.list
        @thread = @accounts.async.list
      end

      it('should start execution') { expect(@thread).to be_alive }
      it 'should get same result as the synchronous method' do
        expect(@thread.value).to eq(@expected)
      end
      it('should complete execution') { expect(@thread).to be_dead }
    end

    context 'method with arguments' do
      before(:all) do
        @uid = @accounts.list[0].uid
        @expected = @accounts.get @uid
        @thread = @accounts.async.get @uid
      end

      it('should start execution') { expect(@thread).to be_alive }
      it 'should get same result as the synchronous method' do
        expect(@thread.value).to eq(@expected)
      end
      it('should complete execution') { expect(@thread).to be_dead }
    end

    context 'several methods in parallel' do
      before(:all) do
        @expected = [@accounts.list, @accounts.add_requirements, @accounts.list]
        @threads = [@accounts.async.list,
                    @accounts.async.add_requirements,
                    @accounts.async.list]
      end

      it('should start execution') { expect(@threads).to all(be_alive) }
      it 'should get same result as the synchronous method' do
        expect(@threads.map { |t| t.value }).to eq(@expected)
      end
      it('should complete execution')  { expect(@threads).to all(be_dead) }
    end
  end

  context 'error handling' do
    it 'should correctly raise error' do
      thread = @accounts.async.get 'nonexistent'
      expect{thread.value}.to raise_error(UtilityApi::Errors::NotFound)
    end

    it 'should fail immediately if calling a nonexistent method' do
      expect{@accounts.async.nonexistent}.to raise_error(NameError)
    end
  end
end
