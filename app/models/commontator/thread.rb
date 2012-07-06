module Commontator
  class Thread < ActiveRecord::Base

    belongs_to :closer, :polymorphic => true
    belongs_to :commontable, :polymorphic => true

    has_many :comments, :dependent => :destroy
    has_many :subscriptions, :dependent => :destroy

    validates_presence_of :commontable, :allow_nil => true
    
    attr_accessible :is_closed
    
    def subscribers
      subscriptions.collect{|s| s.subscriber}
    end
    
    def subscription_for(user)
      Subscription.find_by_thread_id_and_subscriber_id_and_subscriber_type(self.id, user.id, user.class.name)
    end
    
    def is_closed?
      !closed_at.blank?
    end
    
    def config
      commontable.commontable_config
    end
    
    def is_subscribed?(user)
      !subscription_for(subscriber).blank?
    end

    def subscribe(subscriber)
      return false if is_subscribed?(user)
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
    
    def mark_as_unread_except_for(subscriber)
      Subscription.transaction do
        subscriptions.each{|s| s.mark_as_unread unless s.subscriber == subscriber}
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
      self.subscribe(user) if config.auto_subscribe_on_comment
      self.mark_as_unread_except_for(user)
      SubscriptionMailer.comment_created_email(comment)
      commontable.send(config.comment_created_callback, user, comment) unless config.comment_created_callback.blank?
    end
    
    def comment_edited_callback(user, comment)
      commontable.send(config.comment_edited_callback, user, comment) unless config.comment_edited_callback.blank?
    end
    
    def comment_deleted_callback(user, comment)
      commontable.send(config.comment_deleted_callback, user, comment) unless config.comment_deleted_callback.blank?
    end
    
    def thread_closed_callback(user)
      commontable.send(config.thread_closed_callback, user) unless config.thread_closed_callback.blank?
    end
    
    def subscribe_callback(user)
      commontable.send(config.subscribe_callback, user) unless config.subscribe_callback.blank?
    end
          
    def unsubscribe_callback(user)
      commontable.send(config.unsubscribe_callback, user) unless config.unsubscribe_callback.blank?
    end

    ##########################
    # Access control methods #
    ##########################

    def can_be_read_by?(user)
      ((!is_closed? || config.closed_threads_are_readable) &&\
        config.can_read_thread_method.blank? ? true : commontable.send(config.can_read_thread_method, user)) ||\
        can_be_edited_by?(user)
    end

    def can_be_edited_by?(user)
      config.can_edit_thread_method.blank? ?
        (user.commontator_config.is_admin_method.blank? ? false : user.send(user.commontator_config.is_admin_method)) :
        commontable.send(config.can_edit_thread_method, user)
    end

    def can_subscribe?(user)
      config.can_subscribe_to_thread && can_be_read_by?(user)
    end

  end
end
