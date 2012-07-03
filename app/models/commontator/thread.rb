module Commontator
  class Thread < ActiveRecord::Base

    belongs_to :commentable, :polymorphic => true

    has_many :comments, :dependent => :destroy
    has_many :subscriptions, :dependent => :destroy
    has_many :subscribers, :through => :subscriptions

    validates_presence_of :commentable, :allow_nil => true
    validates_uniqueness_of :commentable

    def subscribe(subscriber)
      return false if Subscription.subscription_for(subscriber, self).first
      subscription = Subscription.create(
        :subscriber => subscriber, :thread => self)
      subscribe_callback(subscriber)
    end

    def unsubscribe(subscriber)
      subscription = Subscription.subscription_for(subscriber, self).first
      return false if !subscription
      subscription.destroy
      unsubscribe_callback(subscriber)
    end

    def add_unread_except_for(subscriber)
      subscriptions.each { |cts| cts.add_unread unless cts.subscriber == subscriber }
    end

    def mark_as_read_for(subscriber)
      return if !subscription_for(subscriber)
      subscription_for(subscriber).mark_all_as_read
    end

    def mark_as_unread_for(subscriber)
      return if !subscription_for(subscriber)
      subscription_for(subscriber).mark_all_as_unread
    end
    
    # Creates a new empty thread and assigns it to the commentable
    # The old thread is kept in the database for archival purposes
    def clear
      new_thread = Thread.new
      new_thread.commentable = commentable
      Thread.transaction do
        new_thread.save!
        commentable.comment_thread = new_thread
        commentable.save!
        subscriptions.each do |s|
          s.comment_thread = new_thread
          s.save!
          s.mark_all_as_read!
        end
        self.commentable = nil
        self.is_closed = true
        self.save!
      end
    end
    
    ####################
    # Callback methods #
    ####################
    
    def comment_posted_callback(user, comment)
      self.subscribe(user) if commentable.auto_subscribe_on_comment
      self.add_unread_except_for(user)
      SubscriptionNotifier.comment_created_email(comment)
      commentable.send comment_posted_callback_name, user, comment unless commentable.comment_posted_callback_name.nil?
    end
    
    def comment_edited_callback(user, comment)
      commentable.send comment_edited_callback_name, user, comment unless commentable.comment_edited_callback_name.nil?
    end
    
    def comment_deleted_callback(user, comment)
      commentable.send comment_deleted_callback_name, user, comment unless commentable.comment_deleted_callback_name.nil?
    end
    
    def subscribe_callback(user)
      commentable.send subscribe_callback_name, user unless commentable.subscribe_callback_name.nil?
    end
          
    def unsubscribe_callback(user)
      commentable.send unsubscribe_callback_name, user unless commentable.unsubscribe_callback_name.nil?
    end

    ##########################
    # Access control methods #
    ##########################
    
    def is_thread_admin?(user)
      commentable.commentable_is_admin_method_name.blank? ?
        (user.commenter_is_admin_method_name.blank? ? false : user.send commenter_is_admin_method_name) :
        commentable.send commentable_is_admin_method_name, user
    end

    def can_be_read_by?(user)
      commentable.can_read_thread_method_name.blank? ? true : commentable.send can_read_thread_method_name, user ||\
        is_thread_admin?(user)
    end

    def can_be_edited_by?(user)
      is_thread_admin?(user)
    end

    def can_subscribe?(user)
      commentable.can_subscribe_to_thread && can_be_read_by?(user)
    end

  end
end
