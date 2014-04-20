require 'spec_helper'

module Commontator
  describe ControllerIncludes do
    it 'must add commontator_thread_show to ActionController instances' do
      ActionController::Base.new.respond_to?(:commontator_thread_show, true).must_equal true
      DummyModelsController.new.respond_to?(:commontator_thread_show, true).must_equal true
    end
    
    it 'must add shared helper to ActionController and subclasses' do
      ActionController::Base.helpers.must_respond_to :commontator_thread
      DummyModelsController.helpers.must_respond_to :commontator_thread
    end
  end
end

