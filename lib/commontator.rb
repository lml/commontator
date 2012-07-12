module Commontator
  # Attributes

  # Can be set in initializer only
  ENGINE_ATTRIBUTES = [
    :current_user_method,
    :javascript_proc
  ]

  # Can be set in initializer or passed as an option to acts_as_commontator
  COMMONTATOR_ATTRIBUTES = [
    :commontator_name_clickable,
    :commontator_email_method,
    :commontator_name_method,
    :is_admin_method
  ]
  
  # Can be set in initializer or passed as an option to acts_as_commontable
  COMMONTABLE_ATTRIBUTES = [
    :comment_name,
    :comment_create_verb_present,
    :comment_create_verb_past,
    :commontable_name,
    :commontable_url_proc,
    :subscription_email_subject_proc,
    :timestamp_format,
    :admin_can_edit_comments,
    :auto_subscribe_on_comment,
    :can_edit_own_comments,
    :can_edit_old_comments,
    :can_delete_own_comments,
    :can_delete_old_comments,
    :can_subscribe_to_thread,
    :comments_can_be_voted_on,
    :comments_ordered_by_votes,
    :closed_threads_are_readable,
    :deleted_comments_are_visible,
    :commontable_id_method,
    :can_edit_thread_method,
    :can_read_thread_method,
    :comment_created_callback,
    :comment_edited_callback,
    :comment_deleted_callback,
    :thread_closed_callback,
    :subscribe_callback,
    :unsubscribe_callback
  ]
  
  (ENGINE_ATTRIBUTES + COMMONTATOR_ATTRIBUTES + \
    COMMONTABLE_ATTRIBUTES).each do |attribute|
    mattr_accessor attribute
  end
  
  def self.configure
    yield self
  end
end

require 'commontator/engine'
require 'commontator/commontator_config'
require 'commontator/commontable_config'
require 'commontator/acts_as_commontator'
require 'commontator/acts_as_commontable'
