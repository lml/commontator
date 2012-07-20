require 'spec_helper'

module Commontator
  describe ThreadsHelper do
    before do
      setup_helper_spec
    end
    
    it 'must print commontable name' do
      commontable_name(@thread).must_equal 'dummy model'
    end
    
    it 'must print commontable id' do
      commontable_id(@thread).must_equal @thread.commontable_id
    end
  end
end
