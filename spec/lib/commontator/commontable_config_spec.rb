require 'spec_helper'

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
      proc = lambda { |thread| 'Some name' }
      proc2 = lambda { |thread| 'Another name' }
      config = CommontableConfig.new(:commontable_name_proc => proc)
      (config.commontable_name_proc == proc).must_equal true
      config = CommontableConfig.new(:commontable_name_proc => proc2)
      (config.commontable_name_proc == proc2).must_equal true
    end
  end
end

