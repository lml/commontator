module Commontator
  class Thread < ActiveRecord::Base
    belongs_to :closer, :polymorphic => true
    belongs_to :commontable, :polymorphic => true

    has_many :comments, :dependent => :destroy
    has_many :subscriptions, :dependent => :destroy

    validates_presence_of :commontable, :unless => :is_closed?
    validates_uniqueness_of :commontable_id,
                            :scope => :commontable_type,
                            :allow_nil => true

    def config
      commontable.try(:commontable_config) || Commontator
    end

    def ordered_comments
      case config.comment_order.to_sym
      when :l then comments.order('id DESC')
      when :ve then comments.order('cached_votes_down - cached_votes_up')
      when :vl then comments.order('cached_votes_down - cached_votes_up', 'id DESC')
      else comments
      end
    end

    def is_closed?
      !closed_at.blank?
    end

    def subscribers
      subscriptions.collect{|s| s.subscriber}
    end

    def subscription_for(subscriber)
      return nil if !subscriber || !subscriber.is_commontator
      subscriber.subscriptions.where(:thread_id => self.id).first
    end

    def is_subscribed?(subscriber)
      !subscription_for(subscriber).blank?
    end

    def subscribe(subscriber)
      return false if is_subscribed?(subscriber) || !subscriber.is_commontator
      subscription = Subscription.new
      subscription.subscriber = subscriber
      subscription.thread = self
      subscription.save
    end

    def unsubscribe(subscriber)
      subscription = subscription_for(subscriber)
      return false if subscription.blank?
      subscription.destroy
    end

    def add_unread_except_for(subscriber)
      Subscription.transaction do
        subscriptions.each{|s| s.add_unread unless s.subscriber == subscriber}
      end
    end

    def mark_as_read_for(subscriber)
      return if !subscription_for(subscriber)
      subscription_for(subscriber).mark_as_read
    end

    def close(user = nil)
      return false if is_closed?
      self.closed_at = Time.now
      self.closer = user
      save
    end

    def reopen
      return false unless is_closed? && !commontable.nil?
      self.closed_at = nil
      save
    end

    # Creates a new empty thread and assigns it to the commontable
    # The old thread is kept in the database for archival purposes
    def clear(user = nil)
      return if commontable.blank?
      new_thread = Thread.new
      new_thread.commontable = commontable
      with_lock do
        self.commontable = nil
        self.closed_at = Time.now
        self.closer = user
        save!
        new_thread.save!
        subscriptions.each do |s|
          s.thread = new_thread
          s.save!
          s.mark_as_read
        end
      end
    end

    ##################
    # Access Control #
    ##################

    # Reader capabilities (remember: user can be nil or false)
    def can_be_read_by?(user)
      return true if can_be_edited_by?(user)
      !commontable.nil? && (!is_closed? || !config.hide_closed_threads) &&\
      config.thread_read_proc.call(self, user)
    end

    # Thread moderator capabilities
    def can_be_edited_by?(user)
      !commontable.nil? && !user.nil? && user.is_commontator &&\
      config.thread_moderator_proc.call(self, user)
    end

    def can_subscribe?(user)
      thread_sub = config.thread_subscription.to_sym
      !is_closed? && !user.nil? && user.is_commontator &&\
      thread_sub != :n && thread_sub != :a &&\
      can_be_read_by?(user)
    end
  end
end
