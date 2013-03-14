require 'minitest_helper'

module Commontator
  describe CommontatorConfig do
    it 'must respond to commontator attributes' do
      config = CommontatorConfig.new
      COMMONTATOR_ATTRIBUTES.each do |attribute|
        config.must_respond_to attribute
      end
    end
    
    it 'wont respond to engine or commontable attributes' do
      config = CommontatorConfig.new
      (ENGINE_ATTRIBUTES + COMMONTABLE_ATTRIBUTES).each do |attribute|
        config.wont_respond_to attribute
      end
    end
    
    it 'must be configurable' do
      config = CommontatorConfig.new(:user_missing_name => 'Anon')
      config.user_missing_name.must_equal 'Anon'
      config = CommontatorConfig.new(:user_missing_name => 'Anonymous')
      config.user_missing_name.must_equal 'Anonymous'
    end
  end
end
