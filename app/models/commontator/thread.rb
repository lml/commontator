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
      (!commontable.blank? && config.can_vote_on_comments && config.comments_ordered_by_votes) ? \
        comments.order("cached_votes_down - cached_votes_up") : comments
    end
    
    def subscribers
      subscriptions.collect{|s| s.subscriber}
    end
    
    def active_subscribers
      subscribers.select{|s| s.commontator_config.subscription_email_enable_proc.call(s)}
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
    end

    def unsubscribe(subscriber)
      subscription = subscription_for(subscriber)
      return false if subscription.blank?
      subscription.destroy
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
      return false if is_closed?
      self.closed_at = Time.now
      self.closer = user
      self.save!
    end
    
    def reopen
      return false unless is_closed?
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

    ##########################
    # Access control methods #
    ##########################
    
    # Reader and poster capabilities
    def can_be_read_by?(user)
      (!commontable.blank? && \
        (!is_closed? || config.closed_threads_are_readable) && \
        config.can_read_thread_proc.call(self, user)) || \
        can_be_edited_by?(user)
    end

    # Thread moderator capabilities
    def can_be_edited_by?(user)
      !commontable.blank? && \
        (config.can_edit_thread_proc.call(self, user) || \
        (!user.nil? && user.commontator_config.user_admin_proc.call(user)))
    end

    def can_subscribe?(user)
      !commontable.blank? && config.can_subscribe_to_thread && !is_closed? && can_be_read_by?(user)
    end
  end
end
