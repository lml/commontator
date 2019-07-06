require 'rails_helper'

RSpec.describe Commontator::SharedHelper, type: :lib do
  let(:controller) { DummyModelsController.new }
  before { setup_controller_spec }

  it 'renders a commontator thread' do
    @user.can_read = true
    controller.current_user = @user

    thread_link = controller.view_context.commontator_thread(DummyModel.create)
    expect(thread_link).not_to be_blank
  end
end
