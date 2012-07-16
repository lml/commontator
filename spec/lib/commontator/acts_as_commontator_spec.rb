require 'spec_helper'

describe Commontator::ActsAsCommontator do
  it 'must add methods to ActiveRecord' do
    ActiveRecord::Base.must_respond_to :acts_as_commontator
    ActiveRecord::Base.must_respond_to :is_commontator
    ActiveRecord::Base.is_commontator.must_equal false
  end
  
  it 'must modify models that act_as_commontator' do
    User.is_commontator.must_equal true
    user = User.create
    user.must_respond_to :comments
    user.must_respond_to :subscriptions
    user.must_respond_to :commontator_config
    user.commontator_config.must_be_instance_of Commontator::CommontatorConfig
  end
end
