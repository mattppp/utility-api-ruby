#
# Copyright © 2015, TopCoder, Inc. All rights reserved.
#
# @author TCSASSEMBLER
# @version 0.1.0
#
require 'spec_helper'

describe UtilityApi::Endpoints::AccountsApi do
  before(:all) do
    # instantiate the api class once, as no method modify it
    @accounts_api = described_class.new TOKEN
  end

  let(:list) { @accounts_api.list }

  describe '.list' do
    it('should return non-empty list') { expect(list).not_to be_empty }

    it 'should return list of non-empty Accounts' do
      expect(list).
        to all(be_a(UtilityApi::Models::Account).and be_non_empty_recursive)
    end
  end

  describe '.get' do
    it 'should return same as the list element' do
      expect(@accounts_api.get list[0].uid).to eq(list[0])
    end

    it 'should fail if a nonexistent uid is passed' do
      expect{@accounts_api.get 'nonexistent'}.
        to raise_error(UtilityApi::Errors::NotFound)
    end
  end

  describe '.add_requirements' do
    it 'should return non-empty AddRequirements' do
     expect(@accounts_api.add_requirements).
      to be_a(UtilityApi::Models::AddRequirements).and be_non_empty_recursive
    end
  end

  describe '.modify_requirements' do
    it 'should return non-empty ModifyRequirements' do
      expect(@accounts_api.modify_requirements list[0].uid).
        to be_a(UtilityApi::Models::ModifyRequirements).
        and be_non_empty_recursive
    end

    it 'should fail if a nonexistent uid is passed' do
      expect{@accounts_api.modify_requirements 'nonexistent'}.
        to raise_error(UtilityApi::Errors::NotFound)
    end
  end

  describe '.delete_code' do
    it 'should return a non-empty string' do
      expect(@accounts_api.delete_code list[0].uid).
        to be_a(String).and be_non_empty
    end

    it 'should fail if a nonexistent uid is passed' do
      expect{@accounts_api.delete_code 'nonexistent'}.
        to raise_error(UtilityApi::Errors::NotFound)
    end
  end

  describe '.add' do
    # test cases here include creating a new account, testing its properties,
    # and finally deleting it

    it 'should add an account with auth_type=owner' do
      list_before = @accounts_api.list

      options = build(:account_options, auth_type: 'owner')
      added = @accounts_api.add options

      expected = @accounts_api.get(added.uid).to_h
      expected.delete(:modified)
      expected.delete(:latest)

      expect(added).
        to be_a(UtilityApi::Models::Account).and have_attributes(expected)

      list_after = @accounts_api.list
      expect(list_after[1..-1]).to eq(list_before)
      expect(list_after[0]).to have_attributes(
        utility: options.utility,
        auth_type: options.auth_type,
        auth: options.real_name,
        uid: added.uid
      )

      code = @accounts_api.delete_code added.uid
      @accounts_api.delete added.uid, code
    end

    it 'should add an account with auth_type=3rdparty' do
      list_before = @accounts_api.list

      options = build(:account_options, auth_type: '3rdparty')
      added = @accounts_api.add options

      expected = @accounts_api.get(added.uid).to_h
      expected.delete(:modified)
      expected.delete(:latest)

      expect(added).
        to be_a(UtilityApi::Models::Account).and have_attributes(expected)

      list_after = @accounts_api.list
      expect(list_after[1..-1]).to eq(list_before)
      expect(list_after[0]).to have_attributes(
        utility: options.utility,
        auth_type: options.auth_type,
        auth: "/api/accounts/#{added.uid}/auth.zip",
        uid: added.uid
      )

      code = @accounts_api.delete_code added.uid
      @accounts_api.delete added.uid, code
    end

    it 'should fail if a nonexistent uid is passed' do
     expect{@accounts_api.add build(:account_options, real_name: nil)}.
      to raise_error(UtilityApi::Errors::BadRequest)
    end

    it 'should fail if empty AccountOptions are passed' do
     expect{@accounts_api.add UtilityApi::Models::AccountOptions.new({})}.
      to raise_error(UtilityApi::Errors::BadRequest)
    end
  end

  describe '.auth_file' do
    it 'should work with a 3rdparty-authorized account' do
      added = @accounts_api.add build(:account_options, auth_type: '3rdparty')
      expect(@accounts_api.auth_file added.uid).to be_non_empty

      code = @accounts_api.delete_code added.uid
      @accounts_api.delete added.uid, code
    end

    it 'should not work with a owner-authorized account' do
      added = @accounts_api.add build(:account_options, auth_type: 'owner')
      expect{@accounts_api.auth_file added.uid}.
        to raise_error(UtilityApi::Errors::NotFound)

      code = @accounts_api.delete_code added.uid
      @accounts_api.delete added.uid, code
    end

    it 'should fail if a nonexistent uid is passed' do
      expect{@accounts_api.auth_file 'nonexistent'}.
        to raise_error(UtilityApi::Errors::NotFound)
    end
  end

  describe '.modify' do
    before(:all) do
      # add a single account, which will be modified in different ways
      # and then deleted
      @added = @accounts_api.add build(:account_options, auth_type: 'owner')
    end

    after(:all) do
      code = @accounts_api.delete_code @added.uid
      @accounts_api.delete @added.uid, code
    end

    it 'should change nothing when given empty options' do
      expected = @added.to_h
      expected.delete(:modified)
      expected.delete(:latest)

      options = UtilityApi::Models::AccountOptions.new({})
      expect(@accounts_api.modify(@added.uid, options)).
        to be_a(UtilityApi::Models::Account).and have_attributes(expected)

      expect(@accounts_api.get @added.uid).to have_attributes(expected)
    end

    it 'should change nothing when given same options' do
      expected = @added.to_h
      expected.delete(:modified)
      expected.delete(:latest)

      options = build(:account_options, auth_type: 'owner')
      expect(@accounts_api.modify(@added.uid, options)).
        to be_a(UtilityApi::Models::Account).and have_attributes(expected)

      expect(@accounts_api.get @added.uid).to have_attributes(expected)
    end

    it 'should change real_name' do
      expected = @added.to_h
      expected.delete(:modified)
      expected.delete(:latest)
      expected[:auth] = 'Other Name'

      options = build(:account_options,
                      auth_type: 'owner', real_name: 'Other Name')
      expect(@accounts_api.modify(@added.uid, options)).
        to be_a(UtilityApi::Models::Account).and have_attributes(expected)

      expect(@accounts_api.get @added.uid).to have_attributes(expected)
    end

    it 'should change auth_type' do
      expected = @added.to_h
      expected.delete(:modified)
      expected.delete(:latest)
      expected[:auth_type] = '3rdparty'
      expected[:auth] = "/api/accounts/#{@added.uid}/auth.zip"

      options = build(:account_options, auth_type: '3rdparty')
      expect(@accounts_api.modify(@added.uid, options)).
        to be_a(UtilityApi::Models::Account).and have_attributes(expected)

      expect(@accounts_api.get @added.uid).to have_attributes(expected)
    end

    it 'should fail if a nonexistent uid is passed' do
      expect{@accounts_api.modify 'nonexistent', build(:account_options)}.
        to raise_error(UtilityApi::Errors::NotFound)
    end
  end

  describe '.delete' do
    # test cases here include creating a new account, then deleting it and
    # checking if nothing changed from the beginning

    it 'should delete one account' do
      list_before = @accounts_api.list

      added = @accounts_api.add build(:account_options, auth_type: 'owner')

      code = @accounts_api.delete_code added.uid
      expect(@accounts_api.delete added.uid, code).
        # XXX: service returns uid as int
        to include('success'=>true, 'account_uid'=>added.uid.to_i)

      expect(@accounts_api.list).to eq(list_before)
    end

    it 'should delete two accounts starting from older' do
      list_before = @accounts_api.list

      added = 2.times.map do
        @accounts_api.add build(:account_options, auth_type: 'owner')
      end

      added.each do |acc|
        code = @accounts_api.delete_code acc.uid
        expect(@accounts_api.delete acc.uid, code).
          # XXX: service returns uid as int
          to include('success'=>true, 'account_uid'=>acc.uid.to_i)
      end

      expect(@accounts_api.list).to eq(list_before)
    end

    it 'should fail if a nonexistent uid is passed' do
      expect{@accounts_api.delete 'nonexistent', 'wrongcode'}.
        to raise_error(UtilityApi::Errors::NotFound)
    end

    it 'should fail if a wrong code is passed' do
      expect{@accounts_api.delete list[0].uid, 'wrongcode'}.
        to raise_error(UtilityApi::Errors::BadRequest)
    end
  end
end
