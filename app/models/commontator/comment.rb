module Commontator
  class Comment < ActiveRecord::Base
    belongs_to :creator, :polymorphic => true
    belongs_to :deleter, :polymorphic => true
    belongs_to :thread
    
    has_one :commontable, :through => :thread
    
    validates_presence_of :creator, :on => :create
    validates_presence_of :thread
    validates_presence_of :body

    attr_accessible :body
    
    cattr_accessor :acts_as_votable_initialized
    
    def is_votable?
      return false unless self.class.respond_to?(:acts_as_votable)
      self.class.acts_as_votable unless acts_as_votable_initialized
      self.class.acts_as_votable_initialized = true
    end
    
    def is_modified?
      updated_at != created_at
    end
    
    def is_deleted?
      !deleted_at.blank?
    end
    
    def timestamp
      config = thread.config
      (is_modified? ? 'Last modified on ' : \
        "#{config.comment_create_verb_past.capitalize} on ") + \
        updated_at.strftime(config.timestamp_format)
    end
    
    def delete(user = nil)
      return false if is_deleted?
      self.deleted_at = Time.now
      self.deleter = user
      self.save!
    end
    
    def undelete
      return false unless is_deleted?
      self.deleted_at = nil
      self.save!
    end

    ##########################
    # Access control methods #
    ##########################
    
    def can_be_read_by?(user)
      (thread.can_be_read_by?(user) && (!is_deleted? ||\
        thread.config.deleted_comments_are_visible)) ||\
        thread.can_be_edited_by?(user)
    end

    def can_be_created_by?(user)
      !thread.is_closed? && thread.can_be_read_by?(user) && user == creator
    end

    def can_be_edited_by?(user)
      !thread.is_closed? && !is_deleted? &&\
        ((user == creator && thread.config.can_edit_own_comments && thread.can_be_read_by?(user)) ||\
        (thread.can_be_edited_by?(user) && thread.config.admin_can_edit_comments)) &&\
        (thread.comments.last == self || thread.config.can_edit_old_comments)
    end

    def can_be_deleted_by?(user)
      (!thread.is_closed? &&\
        ((user == creator && thread.config.can_delete_own_comments && \
        thread.can_be_read_by?(user) && (!is_deleted? || deleter == user)) &&\
        (thread.comments.last == self || thread.config.can_delete_old_comments))) ||\
        thread.can_be_edited_by?(user)
    end
    
    def can_be_voted_on?
      is_votable? && !is_deleted? && thread.config.comments_can_be_voted_on
    end

    def can_be_voted_on_by?(user)
      can_be_voted_on? && !thread.is_closed? &&\
        thread.can_be_read_by?(user) && user != creator
    end
  end
end
