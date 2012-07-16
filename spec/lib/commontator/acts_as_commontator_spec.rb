require 'spec_helper'

describe Commontator::ActsAsCommontator do
  it 'must add methods to ActiveRecord and subclasses' do
    ActiveRecord::Base.must_respond_to :acts_as_commontator
    ActiveRecord::Base.must_respond_to :is_commontator
    ActiveRecord::Base.is_commontator.must_equal false
    DummyModel.must_respond_to :acts_as_commontator
    DummyModel.must_respond_to :is_commontator
    DummyModel.is_commontator.must_equal false
    User.must_respond_to :acts_as_commontator
    User.must_respond_to :is_commontator
    User.is_commontator.must_equal true
  end
  
  it 'must modify models that act_as_commontator' do
    user = User.create
    user.must_respond_to :comments
    user.must_respond_to :subscriptions
    user.must_respond_to :commontator_config
    user.commontator_config.must_be_instance_of Commontator::CommontatorConfig
  end
end
