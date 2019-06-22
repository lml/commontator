require 'rails_helper'

RSpec.describe Commontator::ActsAsCommontator, type: :lib do
  it 'adds methods to ActiveRecord and subclasses' do
    expect(ActiveRecord::Base).to respond_to(:acts_as_commontator)
    expect(ActiveRecord::Base).to respond_to(:is_commontator)
    expect(ActiveRecord::Base.is_commontator).to eq false
    expect(DummyModel).to respond_to(:acts_as_commontator)
    expect(DummyModel).to respond_to(:is_commontator)
    expect(DummyModel.is_commontator).to eq false
    expect(DummyUser).to respond_to(:acts_as_commontator)
    expect(DummyUser).to respond_to(:is_commontator)
    expect(DummyUser.is_commontator).to eq true
  end

  it 'modifies models that act_as_commontator' do
    user = DummyUser.create
    expect(user).to respond_to(:comments)
    expect(user).to respond_to(:subscriptions)
    expect(user).to respond_to(:commontator_config)
    expect(user.commontator_config).to be_a(Commontator::CommontatorConfig)
  end
end
