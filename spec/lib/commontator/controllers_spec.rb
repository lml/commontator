require 'rails_helper'

RSpec.describe Commontator::Controllers, type: :lib do
  {
    ActionController::API => DummyApiController,
    ActionController::Base => DummyModelsController
  }.each do |klass, subclass|
    it "adds commontator_thread_show to #{klass.name} instances" do
      expect(klass.new.respond_to?(:commontator_thread_show, true)).to eq true
      expect(subclass.new.respond_to?(:commontator_thread_show, true)).to eq true
    end
  end
end
