module Commontator
  class Comment < ActiveRecord::Base

    acts_as_votable

    belongs_to :thread
    belongs_to :commontator, :polymorphic => true

    has_one :commontable, :through => :thread
    #has_one :subthread, :class_name => "Thread",
    #                    :as => :commontable,
    #                    :dependent => :destroy

    #before_validation :build_subthread, :on => :create
    validates_presence_of :thread, :commontator#, :subthread
    #validates_uniqueness_of :subthread

    attr_accessible :body

    def is_modified?
      updated_at != created_at
    end

    ##########################
    # Access control methods #
    ##########################

    def can_be_created_by?(user)
      thread.can_be_read_by?(user) && user == commontator
    end

    def can_be_edited_by?(user)
      ((user == commontator && thread.can_edit_own_comment?) ||\
      (thread.can_be_edited_by?(user) && thread.admin_can_edit_comments?)) &&\
      (thread.comments.last == self || thread.old_comments_can_be_edited?)
    end

    def can_be_deleted_by?(user)
      ((user == commontator && thread.can_delete_own_comment?) ||\
      (thread.can_be_edited_by?(user) && thread.admin_can_delete_comments?)) &&\
      (thread.comments.last == self || thread.old_comments_can_be_deleted?)
    end
    
    def can_be_voted_on?
      thread.comments_can_be_voted_on?
    end

    def can_be_voted_on_by?(user)
      can_be_voted_on? && thread.can_be_read_by?(user) && user != commontator
    end
    
  end
end
