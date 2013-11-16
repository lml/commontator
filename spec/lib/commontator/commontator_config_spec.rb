require 'test_helper'

module Commontator
  describe CommontatorConfig do
    it 'must respond to commontator attributes' do
      config = CommontatorConfig.new
      COMMONTATOR_ATTRIBUTES.each do |attribute|
        config.must_respond_to attribute
      end
    end
    
    it "won't respond to engine or commontable attributes" do
      config = CommontatorConfig.new
      (ENGINE_ATTRIBUTES + COMMONTABLE_ATTRIBUTES).each do |attribute|
        config.wont_respond_to attribute
      end
    end
    
    it 'must be configurable' do
      config = CommontatorConfig.new(:user_name_clickable => true)
      config.user_name_clickable.must_equal true
      config = CommontatorConfig.new(:user_name_clickable => false)
      config.user_name_clickable.must_equal false
    end
  end
end
