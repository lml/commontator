require 'spec_helper'

describe Commontator do
  it 'must respond to all attributes' do
    (Commontator::ENGINE_ATTRIBUTES + Commontator::COMMONTATOR_ATTRIBUTES + \
      Commontator::COMMONTABLE_ATTRIBUTES).each do |attribute|
      Commontator.must_respond_to attribute
    end
  end
  
  it 'must be configurable' do
    Commontator.configure do |config|
      config.current_user_method = 'user'
    end
    Commontator.current_user_method.must_equal 'user'
    Commontator.configure do |config|
      config.current_user_method = 'current_user'
    end
    Commontator.current_user_method.must_equal 'current_user'
  end
end
