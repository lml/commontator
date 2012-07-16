require 'spec_helper'

describe Commontator::ControllerIncludes do
  it 'must add commontator_thread_show to ActionController instances' do
    ActionController::Base.new.must_respond_to :commontator_thread_show
    DummyModelsController.new.must_respond_to :commontator_thread_show
  end
  
  it 'must add shared helper to ActionController and subclasses' do
    ActionController::Base.helpers.must_respond_to :commontator_thread
    DummyModelsController.helpers.must_respond_to :commontator_thread
  end
end
