require 'spec_helper'

describe Commontator::SharedHelper do
  it 'must show commontator thread' do
    dummy = DummyModel.new
    pp ApplicationController.helpers.commontator_thread(dummy)
  end
end
