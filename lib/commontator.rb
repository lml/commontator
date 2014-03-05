require 'commontator/engine'
require 'commontator/controller_includes'

module Commontator
  # Attributes

  # Can be set in initializer only
  ENGINE_ATTRIBUTES = [
    :current_user_proc,
    :javascript_proc
  ]

  # Can be set in initializer or passed as an option to acts_as_commontator
  COMMONTATOR_ATTRIBUTES = [
    :user_name_proc,
    :user_name_clickable,
    :user_email_proc,
    :user_admin_proc,
    :user_avatar_proc,
    :user_email_enable_proc
  ]
  
  # Can be set in initializer or passed as an option to acts_as_commontable
  COMMONTABLE_ATTRIBUTES = [
    :email_from_proc,
    :moderators_can_edit_comments,
    :auto_subscribe_on_comment,
    :can_edit_own_comments,
    :can_edit_old_comments,
    :can_delete_own_comments,
    :can_delete_old_comments,
    :can_subscribe_to_thread,
    :can_vote_on_comments,
    :combine_upvotes_and_downvotes,
    :comments_order,
    :closed_threads_are_readable,
    :deleted_comments_are_visible,
    :can_read_thread_proc,
    :can_edit_thread_proc,
    :commontable_name_proc,
    :commontable_url_proc
  ]
  
  (ENGINE_ATTRIBUTES + COMMONTATOR_ATTRIBUTES + \
    COMMONTABLE_ATTRIBUTES).each do |attribute|
    mattr_accessor attribute
  end
  
  def self.configure
    yield self
  end
end

require 'commontator/acts_as_commontator'
require 'commontator/acts_as_commontable'
