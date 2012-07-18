class DummyUser < ActiveRecord::Base
  acts_as_commontator
  
  attr_accessor :is_admin, :can_edit, :can_read
  
  def email
    'user@example.com'
  end
end
