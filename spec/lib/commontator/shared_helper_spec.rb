require 'test_helper'

module Commontator
  describe SharedHelper do
    it 'must show commontator thread' do
      controller = DummyModelsController.new
      # Workaround for https://github.com/rails/rails/issues/11662
      controller.define_singleton_method(:params) do
        {}
      end
      thread_link = controller.view_context.commontator_thread(DummyModel.create)
      thread_link.wont_be_nil
      thread_link.wont_be_empty
    end
  end
end
