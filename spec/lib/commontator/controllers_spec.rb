require 'rails_helper'

RSpec.describe Commontator::Controllers, type: :lib do
  it 'adds shared helper to ActionController and subclasses' do
    expect(ActionController::Base.helpers).to respond_to(:commontator_thread)
    expect(DummyModelsController.helpers).to respond_to(:commontator_thread)
  end

  it 'adds commontator_thread_show to ActionController instances' do
    expect(ActionController::Base.new.respond_to?(:commontator_thread_show, true)).to eq true
    expect(DummyModelsController.new.respond_to?(:commontator_thread_show, true)).to eq true
  end
end
