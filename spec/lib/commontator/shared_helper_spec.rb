require 'rails_helper'

RSpec.describe Commontator::SharedHelper, type: :lib do
  let(:controller) { DummyModelsController.new }
  before { setup_controller_spec }

  {
    ActionController::API => DummyApiController,
    ActionController::Base => DummyModelsController
  }.each do |klass, subclass|
    it "adds commontator_thread to #{klass.name} instances" do
      expect(klass.new.respond_to?(:commontator_thread, true)).to eq true
      expect(subclass.new.respond_to?(:commontator_thread, true)).to eq true
    end
  end

  it 'adds itself as a helper to ActionController::Base and subclasses' do
    expect(ActionController::Base.helpers).to respond_to(:commontator_thread)
    expect(DummyModelsController.helpers).to respond_to(:commontator_thread)
  end

  it 'renders a commontator thread' do
    @user.can_read = true
    controller.current_user = @user

    thread_link = controller.view_context.commontator_thread(DummyModel.create)
    expect(thread_link).not_to be_blank
  end
end
