module Commontator
  class Thread < ActiveRecord::Base
    belongs_to :closer, :polymorphic => true
    belongs_to :commontable, :polymorphic => true

    has_many :comments, :dependent => :destroy
    has_many :subscriptions, :dependent => :destroy

    validates_presence_of :commontable, :on => :create
    
    attr_accessible :is_closed
    
    def config
      commontable.try(:commontable_config)
    end
    
    def ordered_comments
      (!commontable.blank? && config.comments_can_be_voted_on && config.comments_ordered_by_votes) ? \
        comments.order("cached_votes_down - cached_votes_up") : comments
    end
    
    def subscribers
      subscriptions.collect{|s| s.subscriber}
    end
    
    def subscription_for(subscriber)
      return nil if subscriber.nil?
      Subscription.find_by_thread_id_and_subscriber_id_and_subscriber_type(self.id, subscriber.id, subscriber.class.name)
    end
    
    def is_closed?
      !closed_at.blank?
    end
    
    def is_subscribed?(subscriber)
      !subscription_for(subscriber).blank?
    end

    def subscribe(subscriber)
      return false if is_subscribed?(subscriber)
      subscription = Subscription.create(
        :subscriber => subscriber, :thread => self)
      subscribe_callback(subscriber)
    end

    def unsubscribe(subscriber)
      subscription = subscription_for(subscriber)
      return false if subscription.blank?
      subscription.destroy
      unsubscribe_callback(subscriber)
    end

    def mark_as_read_for(subscriber)
      return if !subscription_for(subscriber)
      subscription_for(subscriber).mark_as_read
    end
    
    def add_unread_except_for(subscriber)
      Subscription.transaction do
        subscriptions.each{|s| s.add_unread unless s.subscriber == subscriber}
      end
    end
    
    def close(user = nil)
      self.closed_at = Time.now
      self.closer = user
      self.save!
    end
    
    def reopen
      self.closed_at = nil
      self.save!
    end
    
    # Creates a new empty thread and assigns it to the commontable
    # The old thread is kept in the database for archival purposes
    
    def clear(user = nil)
      return if commontable.blank?
      new_thread = Thread.new
      new_thread.commontable = commontable
      self.with_lock do
        new_thread.save!
        commontable.thread = new_thread
        commontable.save!
        subscriptions.each do |s|
          s.thread = new_thread
          s.save!
          s.mark_as_read
        end
        self.commontable = nil
        self.close(user)
      end
    end
    
    ####################
    # Callback methods #
    ####################
    
    def comment_created_callback(user, comment)
      commontable.blank? || config.comment_created_callback.blank? || commontable.send(config.comment_created_callback, user, comment)
    end
    
    def comment_edited_callback(user, comment)
      commontable.blank? || config.comment_edited_callback.blank? || commontable.send(config.comment_edited_callback, user, comment)
    end
    
    def comment_deleted_callback(user, comment)
      commontable.blank? || config.comment_deleted_callback.blank? || commontable.send(config.comment_deleted_callback, user, comment)
    end
    
    def thread_closed_callback(user)
      commontable.blank? || config.thread_closed_callback.blank? || commontable.send(config.thread_closed_callback, user)
    end
    
    def subscribe_callback(user)
      commontable.blank? || config.subscribe_callback.blank? || commontable.send(config.subscribe_callback, user)
    end
          
    def unsubscribe_callback(user)
      commontable.blank? || config.unsubscribe_callback.blank? || commontable.send(config.unsubscribe_callback, user)
    end

    ##########################
    # Access control methods #
    ##########################

    def can_be_read_by?(user) # Reader and poster capabilities
      (!commontable.blank? && (!is_closed? || config.closed_threads_are_readable) &&\
        config.can_read_thread_method.blank? ? true : commontable.send(config.can_read_thread_method, user)) ||\
        can_be_edited_by?(user)
    end

    def can_be_edited_by?(user) # Thread admin capabilities
      !commontable.blank? && (config.can_edit_thread_method.blank? ?
        (user.commontator_config.is_admin_method.blank? ? false : user.send(user.commontator_config.is_admin_method)) :
        commontable.send(config.can_edit_thread_method, user))
    end

    def can_subscribe?(user)
      !commontable.blank? && config.can_subscribe_to_thread && !is_closed? && can_be_read_by?(user)
    end
  end
end
