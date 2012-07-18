class DummyUser < ActiveRecord::Base
  acts_as_commontator
  
  attr_accessor :is_admin
  
  def email
    'user@example.com'
  end
end
