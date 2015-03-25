#
# Copyright © 2015, TopCoder, Inc. All rights reserved.
#
# @author TCSASSEMBLER
# @version 0.1.0
#
require 'spec_helper'

describe UtilityApi::Client do
  before(:all) do
    @client = described_class.new TOKEN
    @accounts = UtilityApi::Endpoints::AccountsApi.new TOKEN
    @services = UtilityApi::Endpoints::ServicesApi.new TOKEN
  end

  describe '.accounts' do
    it 'should be an AccountsApi' do
      expect(@client.accounts).to be_a(UtilityApi::Endpoints::AccountsApi)
    end

    it 'should return same results' do
      expect(@client.accounts.list).to eq(@accounts.list)
    end
  end

  describe '.services' do
    it 'should be a ServicesApi' do
      expect(@client.services).to be_a(UtilityApi::Endpoints::ServicesApi)
    end

    it 'should return same results' do
      expect(@client.services.list).to eq(@services.list)
    end
  end

  describe '.accounts_utilities' do
    it 'should be an AccountsUtilities' do
      expect(@client.accounts_utilities).to be_a(UtilityApi::AccountsUtilities)
    end
  end
end
