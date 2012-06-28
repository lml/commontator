class CommentThread::Comment < ActiveRecord::Base

  acts_as_votable

  belongs_to :comment_thread
  belongs_to :creator, :polymorphic => true

  has_one :subthread, :class_name => "CommentThread",
                      :as => :commentable,
                      :dependent => :destroy

  before_validation :build_subthread, :on => :create
  validates_presence_of :comment_thread, :creator, :subthread
  validates_uniqueness_of :subthread

  attr_accessible :body

  def is_modified?
    updated_at != created_at
  end

  ##########################
  # Access control methods #
  ##########################

  def can_be_read_by?(user)
    comment_thread.can_be_read_by?(user)
  end

  def can_be_created_by?(user)
    comment_thread.can_be_read_by?(user)
  end

  def can_be_updated_by?(user)
    CommentThread::Thread.comments_can_be_edited? &&
    ((user == creator && CommentThread::CommentThread.creator_can_edit_comment?) ||\
    (comment_thread.can_be_updated_by?(user) && CommentThread::Thread.manager_can_edit_comment?)) &&\
    (comment_thread.comments.last == self || CommentThread::Thread.old_comments_can_be_edited?)
  end

  def can_be_destroyed_by?(user)
    CommentThread::Thread.comments_can_be_deleted? &&
    ((user == creator && CommentThread::CommentThread.creator_can_delete_comment?) ||\
    (comment_thread.can_be_updated_by?(user) && CommentThread::Thread.manager_can_delete_comment?)) &&\
    (comment_thread.comments.last == self || CommentThread::Thread.old_comments_can_be_deleted?)
  end

  def can_be_voted_on_by?(user)
    CommentThread::Thread.comments_can_be_voted_on? && comment_thread.can_be_read_by?(user)
  end

end
