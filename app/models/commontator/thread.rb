module Commontator
  class Thread < ActiveRecord::Base

    belongs_to :commontable, :polymorphic => true

    has_many :comments, :dependent => :destroy
    has_many :subscriptions, :dependent => :destroy
    has_many :subscribers, :through => :subscriptions

    validates_presence_of :commontable, :allow_nil => true
    validates_uniqueness_of :commontable
    
    def config
      commontable.commontable_config
    end

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
      new_thread.commontable = commontable
      Thread.transaction do
        new_thread.save!
        commontable.comment_thread = new_thread
        commontable.save!
        subscriptions.each do |s|
          s.thread = new_thread
          s.save!
          s.mark_all_as_read!
        end
        self.commontable = nil
        self.is_closed = true
        self.save!
      end
    end
    
    ####################
    # Callback methods #
    ####################
    
    def comment_posted_callback(user, comment)
      self.subscribe(user) if config.auto_subscribe_on_comment
      self.add_unread_except_for(user)
      SubscriptionNotifier.comment_created_email(comment)
      commontable.send config.comment_posted_callback, user, comment unless config.comment_posted_callback.blank?
    end
    
    def comment_edited_callback(user, comment)
      commontable.send config.comment_edited_callback, user, comment unless config.comment_edited_callback.blank?
    end
    
    def comment_deleted_callback(user, comment)
      commontable.send config.comment_deleted_callback, user, comment unless config.comment_deleted_callback.blank?
    end
    
    def subscribe_callback(user)
      commontable.send config.subscribe_callback, user unless config.subscribe_callback.blank?
    end
          
    def unsubscribe_callback(user)
      commontable.send config.unsubscribe_callback, user unless config.unsubscribe_callback.blank?
    end

    ##########################
    # Access control methods #
    ##########################

    def can_be_read_by?(user)
      config.can_read_thread_method.blank? ? true : commentable.send config.can_read_thread_method, user ||\
        can_be_edited_by?(user)
    end

    def can_be_edited_by?(user)
      config.can_edit_thread_method.blank? ?
        (user.commontator_config.is_admin_method.blank? ? false : user.send user.commontator_config.is_admin_method) :
        commontable.send config.can_edit_thread_method, user
    end

    def can_subscribe?(user)
      config.can_subscribe_to_thread && can_be_read_by?(user)
    end

  end
end
