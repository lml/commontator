require 'spec_helper'

module Commontator
  describe SharedHelper do
    it 'must show commontator thread' do
      view_context = DummyModelsController.new.view_context
      thread_link = view_context.commontator_thread(DummyModel.create)
      thread_link.wont_be_nil
      thread_link.wont_be_empty
    end
  end
end
