require 'spec_helper'

module Commontator
  describe Commontator do
    it 'must respond to all attributes' do
      (ENGINE_ATTRIBUTES + COMMONTATOR_ATTRIBUTES + \
        COMMONTABLE_ATTRIBUTES).each do |attribute|
        Commontator.must_respond_to attribute
      end
    end
    
    it 'must be configurable' do
      l1 = lambda { |controller| controller.current_user }
      l2 = lambda { |controller| controller.current_user }
      Commontator.configure do |config|
        config.current_user_proc = l1
      end
      assert_equal(Commontator.current_user_proc, l1)
      Commontator.configure do |config|
        config.current_user_proc = l2
      end
      assert_equal(Commontator.current_user_proc, l2)
    end
  end
end
