require 'spec_helper'

module Commontator
  describe ActsAsCommontable do
    it 'must add methods to ActiveRecord and subclasses' do
      ActiveRecord::Base.must_respond_to :acts_as_commontable
      ActiveRecord::Base.must_respond_to :is_commontable
      ActiveRecord::Base.is_commontable.must_equal false
      DummyModel.must_respond_to :acts_as_commontable
      DummyModel.must_respond_to :is_commontable
      DummyModel.is_commontable.must_equal true
      DummyUser.must_respond_to :acts_as_commontable
      DummyUser.must_respond_to :is_commontable
      DummyUser.is_commontable.must_equal false
    end
    
    it 'must modify models that act_as_commontable' do
      dummy = DummyModel.create
      dummy.must_respond_to :thread
      dummy.must_respond_to :commontable_config
      dummy.commontable_config.must_be_instance_of CommontableConfig
    end
  end
end
