#
# Copyright © 2015, TopCoder, Inc. All rights reserved.
#
# @author TCSASSEMBLER
# @version 0.1.0
#
require 'spec_helper'

describe UtilityApi::AccountsUtilities do
  before(:all) do
    @accounts_utilities = described_class.new TOKEN
    @accounts = UtilityApi::Endpoints::AccountsApi.new TOKEN
    @services = UtilityApi::Endpoints::ServicesApi.new TOKEN
  end

  describe '.create_account' do
    it 'should create and return same data as separate methods' do
      options = build(:account_options, auth_type: 'owner')
      res = @accounts_utilities.create_account options

      expect(res[:account]).to be_a(UtilityApi::Models::Account)
      expect(res[:service]).to be_a(UtilityApi::Models::Service)
      expect(res[:bills]).to all(be_a(UtilityApi::Models::Bill))

      expect(res[:account]).to eq(@accounts.get res[:account].uid)
      expect(res[:service]).to eq(@services.get res[:service].uid)
      expect(res[:bills]).to eq(@services.bills res[:service].uid)

      code = @accounts.delete_code res[:account].uid
      @accounts.delete res[:account].uid, code
    end

    it 'should fail if incomplete AccountOptions are passed' do
      options = build(:account_options, auth_type: 'owner', real_name: nil)
      expect{@accounts_utilities.create_account(options)}.
        to raise_error(UtilityApi::Errors::BadRequest)
    end

    it 'should fail if empty AccountOptions are passed' do
      options = UtilityApi::Models::AccountOptions.new({})
      expect{@accounts_utilities.create_account(options)}.
        to raise_error(UtilityApi::Errors::BadRequest)
    end
  end
end
