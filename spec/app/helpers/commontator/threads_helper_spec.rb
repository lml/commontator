require 'test_helper'

module Commontator
  describe ThreadsHelper do
    before do
      setup_helper_spec
    end
    
    it 'must print commontable name' do
      commontable_name(@thread).must_equal 'DummyModel #2'
    end
  end
end
