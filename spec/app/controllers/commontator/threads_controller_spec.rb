require 'spec_helper'

describe Commontator::ThreadsController do
  it 'must get show' do
    thread = Commontator::Thread.new
    thread.commontable = thread
    thread.save!
    thread.commontable = nil
    thread.save!
    get :show, :id => 1, :use_route => :commontator
  end
end
