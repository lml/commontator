require 'rails_helper'

RSpec.describe Commontator::ActsAsCommontable, type: :lib do
  it 'adds methods to ActiveRecord and subclasses' do
    expect(ActiveRecord::Base).to respond_to(:acts_as_commontable)
    expect(ActiveRecord::Base).to respond_to(:is_commontable)
    expect(ActiveRecord::Base.is_commontable).to eq false
    expect(DummyModel).to respond_to(:acts_as_commontable)
    expect(DummyModel).to respond_to(:is_commontable)
    expect(DummyModel.is_commontable).to eq true
    expect(DummyUser).to respond_to(:acts_as_commontable)
    expect(DummyUser).to respond_to(:is_commontable)
    expect(DummyUser.is_commontable).to eq false
  end

  it 'modifies models that act_as_commontable' do
    dummy = DummyModel.create
    expect(dummy).to respond_to(:commontator_thread)
    expect(dummy).to respond_to(:commontable_config)
    expect(dummy.commontable_config).to be_a(Commontator::CommontableConfig)
  end
end
