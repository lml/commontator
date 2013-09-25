module Commontator
  class Subscription < ActiveRecord::Base
    belongs_to :subscriber, :polymorphic => true
    belongs_to :thread

    validates_presence_of :subscriber, :thread
    validates_uniqueness_of :thread_id, :scope => [:subscriber_type, :subscriber_id]

    def mark_as_read
      update_attribute(:unread, 0)
    end

    def add_unread
      update_attribute(:unread, unread + 1)
    end
  end
end
