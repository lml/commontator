require 'spec_helper'

describe Commontator::SharedHelper do
  it 'must show commontator thread' do
    view_context = DummyModelsController.new.view_context
    view_context.commontator_thread(DummyModel.create).wont_be_empty
  end
end
