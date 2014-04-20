require 'spec_helper'

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
      proc = lambda { |user| 'Some name' }
      proc2 = lambda { |user| 'Another name' }
      config = CommontatorConfig.new(:user_name_proc => proc)
      (config.user_name_proc == proc).must_equal true
      config = CommontatorConfig.new(:user_name_proc => proc2)
      (config.user_name_proc == proc2).must_equal true
    end
  end
end

