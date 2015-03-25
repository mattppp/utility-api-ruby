#
# Copyright © 2015, TopCoder, Inc. All rights reserved.
#
# @author TCSASSEMBLER
# @version 0.1.0
#
require 'spec_helper'

describe UtilityApi::Endpoints::ServicesApi do
  before(:all) do
    # instantiate the api class once, as no method modify it
    @services = described_class.new TOKEN
    # get the list once for speed, as there are many places where it is used
    @list = @services.list
  end

  describe '.list' do
    it('should return non-empty list') { expect(@list).not_to be_empty }

    it 'should return list of non-empty Services' do
      expect(@list).
        to all(be_a(UtilityApi::Models::Service).and be_non_empty_recursive)
    end
  end

  describe '.list_for_account' do
    it 'should return correct list' do
      expect(@services.list_for_account @list[0].account_uid).
        to eq(@list.select { |svc| svc.account_uid == @list[0].account_uid })
    end

    it 'should fail if a nonexistent uid is passed' do
      expect{@services.list_for_account 'nonexistent'}.
        # XXX: the service should return 404 code!
        to raise_error(UtilityApi::Errors::BaseError)
    end
  end

  describe '.get' do
    it 'should return same as the list element' do
      expect(@services.get @list[0].uid).to eq(@list[0])
    end

    it 'should fail if a nonexistent uid is passed' do
      expect{@services.get 'nonexistent'}.
        to raise_error(UtilityApi::Errors::NotFound)
    end
  end

  describe '.bills' do
    before(:all) do
      # service is chosen and bills are loaded once
      @svc = @list.select { |svc| svc.bill_count > 0 }.first
      @bills = @services.bills @svc.uid
    end

    it 'should return list of non-empty Bills' do
      expect(@bills).
        to all(be_a(UtilityApi::Models::Bill).and be_non_empty_recursive)
    end

    it 'should contain correct number of bills' do
      expect(@bills.count).to eq(@svc.bill_count)
    end

    it 'should fail if a nonexistent uid is passed' do
      expect{@services.bills 'nonexistent'}.
        to raise_error(UtilityApi::Errors::NotFound)
    end
  end

  describe '.bill_raw' do
    before(:all) do
      # service is chosen and bills are loaded once
      @svc = @list.select { |svc| svc.bill_count > 0 }.first
      @bills = @services.bills @svc.uid
      @bills_fname = @bills.first.source.split('/').last
    end

    it 'should return non-empty result' do
      expect(@services.bill_raw @svc.uid, @bills_fname).to be_non_empty
    end

    it 'should fail if a nonexistent uid is passed' do
      expect{@services.bill_raw 'nonexistent', 'nonexistent'}.
        to raise_error(UtilityApi::Errors::NotFound)
    end

    it 'should fail if a nonexistent bill filename is passed' do
      expect{@services.bill_raw @svc.uid, 'nonexistent'}.
        to raise_error(UtilityApi::Errors::NotFound)
    end
  end

  describe '.bills_archive' do
    it 'should return non-empty result for a service with bills' do
      svc = @list.select { |svc| svc.bill_count > 0 }.first
      expect(@services.bills_archive svc.uid).to be_non_empty
    end

    it 'should fail if a nonexistent uid is passed' do
      expect{@services.bills_archive 'nonexistent'}.
        to raise_error(UtilityApi::Errors::NotFound)
    end
  end

  describe '.intervals' do
    before(:all) do
      # service is chosen and intervals are loaded once
      @svc = @list.select {|svc| svc.interval_count > 0}.first
      @intervals = @services.intervals @svc.uid
    end

    it 'should return list of non-empty Intervals' do
      expect(@intervals).
        to all(be_a(UtilityApi::Models::Interval).and be_non_empty_recursive)
    end

    it 'should contain correct number of intervals' do
      expect(@intervals.count).to eq(@svc.interval_count)
    end

    it 'should fail if a nonexistent uid is passed' do
      expect{@services.intervals 'nonexistent'}.
        to raise_error(UtilityApi::Errors::NotFound)
    end
  end

  describe '.modify_requirements' do
    it 'should return non-empty ModifyRequirements' do
      expect(@services.modify_requirements @list[0].uid).
        to be_a(UtilityApi::Models::ModifyRequirements).
        and be_non_empty_recursive
    end

    it 'should fail if a nonexistent uid is passed' do
      expect{@services.modify_requirements 'nonexistent'}.
        to raise_error(UtilityApi::Errors::NotFound)
    end
  end

  describe '.reset_code' do
    it 'should return a non-empty string' do
      expect(@services.reset_code @list[0].uid).
        to be_a(String).and be_non_empty
    end

    it 'should fail if a nonexistent uid is passed' do
      expect{@services.reset_code 'nonexistent'}.
        to raise_error(UtilityApi::Errors::NotFound)
    end
  end

  describe '.modify' do
    it 'should change nothing when given empty options' do
      uid = @list[0].uid
      expected = @list[0].to_h
      expected.delete(:latest)
      expected.delete(:bill_coverage)
      expected.delete(:interval_coverage)

      expect(@services.modify uid, UtilityApi::Models::ServiceOptions.new({})).
        to be_a(UtilityApi::Models::Service).and have_attributes(expected)

      expect(@services.get uid).to have_attributes(expected)
    end

    it 'should change active_until' do
      uid = @list[0].uid
      expected = @list[0].to_h
      expected.delete(:latest)
      expected.delete(:bill_coverage)
      expected.delete(:interval_coverage)
      expected[:active_until] += 123

      options = UtilityApi::Models::ServiceOptions.new(
        active_until: expected[:active_until])
      expect(@services.modify(uid, options)).
        to be_a(UtilityApi::Models::Service).and have_attributes(expected)

      expect(@services.get uid).to have_attributes(expected)
    end

    it 'should fail if a nonexistent uid is passed' do
      expect{@services.modify 'nonexistent', @list[0]}.
        to raise_error(UtilityApi::Errors::NotFound)
    end
  end

  describe '.reset' do
    it 'should reset a service, deleting all the bills' do
      # this test takes a while, as it is required to wait for the
      # account and service to be ready
      @accounts_utilities = UtilityApi::AccountsUtilities.new TOKEN

      options = build(:account_options, auth_type: 'owner')
      res = @accounts_utilities.create_account options
      acc = res[:account]
      svc = res[:service]

      code = @services.reset_code(svc.uid)
      expect(@services.reset(svc.uid, code)).
          # XXX: service returns uid as int
          to include('success'=>true, 'service_uid'=>svc.uid.to_i)
      expect(@services.bills(svc.uid)).to be_empty

      code = @accounts_utilities.accounts.delete_code(acc.uid)
      @accounts_utilities.accounts.delete(acc.uid, code)
    end

    it 'should fail if a wrong code is passed' do
      expect{@services.reset @list[0].uid, 'wrongcode'}.
        to raise_error(UtilityApi::Errors::BadRequest)
    end

    it 'should fail if a nonexistent uid is passed' do
      expect{@services.reset 'nonexistent', 'wrongcode'}.
        to raise_error(UtilityApi::Errors::NotFound)
    end
  end
end
