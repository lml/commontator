require 'minitest_helper'

module Commontator
  describe CommontableConfig do
    it 'must respond to commontable attributes' do
      config = CommontableConfig.new
      COMMONTABLE_ATTRIBUTES.each do |attribute|
        config.must_respond_to attribute
      end
    end
    
    it 'wont respond to engine or commontator attributes' do
      config = CommontableConfig.new
      (ENGINE_ATTRIBUTES + COMMONTATOR_ATTRIBUTES).each do |attribute|
        config.wont_respond_to attribute
      end
    end
    
    it 'must be configurable' do
      config = CommontableConfig.new(:comment_create_verb_present => 'create')
      config.comment_create_verb_present.must_equal 'create'
      config = CommontableConfig.new(:comment_create_verb_present => 'post')
      config.comment_create_verb_present.must_equal 'post'
    end
  end
end
