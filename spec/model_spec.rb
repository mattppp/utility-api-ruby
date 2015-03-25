#
# Copyright © 2015, TopCoder, Inc. All rights reserved.
#
# @author TCSASSEMBLER
# @version 0.1.0
#
require 'spec_helper'
require 'json'

describe UtilityApi::Models::BaseModel do
  # Testing is performed for a single specific model class: ModifyRequirements.
  # This covers all the features, and testing all model here would just result
  # in repeating code, which wouldn't help in finding errors.

  # hash with the model attribute values
  # keys have to be Strings because in reality such hash will be a parsed json
  let(:data) do
    {
      'account' => {'uid' => '123'},
      'help' => 'help text',
      'docs' => 'doc text',
      'options' => [
        {'name' => 'option 1'},
        {'name' => 'option 2',
         'utility' => 'ut',
         'options' => [{'name' => 'opt name'}]}
      ]
    }
  end

  let(:model) { UtilityApi::Models::ModifyRequirements.new data }

  it 'should be of the correct type' do
    expect(model).
      to be_a(UtilityApi::Models::ModifyRequirements).
      and be_a(Struct)
  end

  it 'should store raw attributes' do
    expect(model.help).to eq(data['help'])
    expect(model.docs).to eq(data['docs'])
  end

  it 'should store attribute which changes name and type' do
    expect(model.object).to be_a(UtilityApi::Models::Account)
    expect(model.object.uid).to eq(data['account']['uid'])
  end

  it 'should store lists' do
    expect(model.options).to be_a(Array)
    expect(model.options.count).to eq(2)
  end

  it 'should store nested models' do
    expect(model.options[0]).
      to be_a(UtilityApi::Models::AddModifyOption).
      and have_attributes(name: data['options'][0]['name'])
    expect(model.options[1]).
      to be_a(UtilityApi::Models::AddModifyUtility).
      and have_attributes(name: data['options'][1]['name'],
                          utility: data['options'][1]['utility'])
    expect(model.options[1].options[0]).
      to be_a(UtilityApi::Models::AddModifyUtilityOption).
      and have_attributes(name: data['options'][1]['options'][0]['name'])
  end

  it 'should serialize to json dropping nil fields' do
    @hash_expected = data.dup
    @hash_expected['object'] = @hash_expected.delete('account')
    expect(JSON.parse model.to_json).to eq(@hash_expected)
  end
end
