module Commontator
  class Comment < ActiveRecord::Base

    acts_as_votable

    belongs_to :thread
    belongs_to :commenter, :polymorphic => true

    has_one :subthread, :class_name => "Thread",
                        :as => :commentable,
                        :dependent => :destroy

    before_validation :build_subthread, :on => :create
    validates_presence_of :thread, :commenter, :subthread
    validates_uniqueness_of :subthread

    attr_accessible :body

    def is_modified?
      updated_at != created_at
    end

    ##########################
    # Access control methods #
    ##########################

    def can_be_read_by?(user)
      thread.can_be_read_by?(user)
    end

    def can_be_created_by?(user)
      thread.can_be_read_by?(user)
    end

    def can_be_updated_by?(user)
      Thread.comments_can_be_edited? &&
      ((user == commenter && Thread.creator_can_edit_comment?) ||\
      (thread.can_be_updated_by?(user) && Thread.manager_can_edit_comment?)) &&\
      (thread.comments.last == self || Thread.old_comments_can_be_edited?)
    end

    def can_be_destroyed_by?(user)
      Thread.comments_can_be_deleted? &&
      ((user == commenter && Thread.creator_can_delete_comment?) ||\
      (thread.can_be_updated_by?(user) && Thread.manager_can_delete_comment?)) &&\
      (thread.comments.last == self || Thread.old_comments_can_be_deleted?)
    end

    def can_be_voted_on_by?(user)
      Thread.comments_can_be_voted_on? && thread.can_be_read_by?(user)
    end

  end
end
