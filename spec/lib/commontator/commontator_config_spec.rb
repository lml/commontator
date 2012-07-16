require 'spec_helper'

describe Commontator::CommontatorConfig do
  it 'must respond to commontator attributes' do
    config = Commontator::CommontatorConfig.new
    Commontator::COMMONTATOR_ATTRIBUTES.each do |attribute|
      config.must_respond_to attribute
    end
  end
  
  it 'wont respond to engine or commontable attributes' do
    config = Commontator::CommontatorConfig.new
    (Commontator::ENGINE_ATTRIBUTES + Commontator::COMMONTABLE_ATTRIBUTES).each do |attribute|
      config.wont_respond_to attribute
    end
  end
  
  it 'must be configurable' do
    config = Commontator::CommontatorConfig.new(:user_missing_name => 'Anon')
    config.user_missing_name.must_equal 'Anon'
    config = Commontator::CommontatorConfig.new(:user_missing_name => 'Anonymous')
    config.user_missing_name.must_equal 'Anonymous'
  end
end
