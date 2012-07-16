require 'spec_helper'

describe Commontator::ActsAsCommontable do
  it 'must add methods to ActiveRecord' do
    ActiveRecord::Base.must_respond_to :acts_as_commontable
    ActiveRecord::Base.must_respond_to :is_commontable
    ActiveRecord::Base.is_commontable.must_equal false
  end
  
  it 'must modify models that act_as_commontable' do
    DummyModel.is_commontable.must_equal true
    dummy = DummyModel.create
    dummy.must_respond_to :thread
    dummy.must_respond_to :comments
    dummy.must_respond_to :subscriptions
    dummy.must_respond_to :commontable_config
    dummy.commontable_config.must_be_instance_of Commontator::CommontableConfig
  end
end
