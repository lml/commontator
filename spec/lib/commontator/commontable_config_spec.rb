require 'test_helper'

module Commontator
  describe CommontableConfig do
    it 'must respond to commontable attributes' do
      config = CommontableConfig.new
      COMMONTABLE_ATTRIBUTES.each do |attribute|
        config.must_respond_to attribute
      end
    end
    
    it "won't respond to engine or commontator attributes" do
      config = CommontableConfig.new
      (ENGINE_ATTRIBUTES + COMMONTATOR_ATTRIBUTES).each do |attribute|
        config.wont_respond_to attribute
      end
    end
    
    it 'must be configurable' do
      config = CommontableConfig.new(:moderators_can_edit_comments => true)
      config.moderators_can_edit_comments.must_equal true
      config = CommontableConfig.new(:moderators_can_edit_comments => false)
      config.moderators_can_edit_comments.must_equal false
    end
  end
end
