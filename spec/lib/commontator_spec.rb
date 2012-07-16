require 'spec_helper'

describe Commontator do
  it 'should respond to all attributes' do
    (Commontator::ENGINE_ATTRIBUTES + Commontator::COMMONTATOR_ATTRIBUTES + \
      Commontator::COMMONTABLE_ATTRIBUTES).each do |attribute|
      Commontator.must_respond_to attribute
    end
  end
  
  it 'should be configurable' do
    Commontator.configure do |config|
      config.comment_create_verb_present = 'create'
    end
    Commontator.comment_create_verb_present.must_equal 'create'
    Commontator.configure do |config|
      config.comment_create_verb_present = 'post'
    end
    Commontator.comment_create_verb_present.must_equal 'post'
  end
end
