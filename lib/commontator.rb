require 'commontator/engine'
require 'commontator/routes'
require 'commontator/acts_as_commentable'
require 'commontator/acts_as_commenter'

DEFAULTS = {:current_user_method => 'current_user',
            :comment_name => 'comment',
            :comment_create_action_name => 'post',
            :comment_created_action_name => 'posted',
            :comment_update_action_name => 'edit',
            :comment_updated_action_name => 'edited',
            :comments_can_be_voted_on => true,
            :can_subscribe_to_thread => true,
            :auto_subscribe_on_comment => false,
            :can_edit_own_comments => true,
            :can_edit_old_comments => false,
            :can_delete_own_comments => false,
            :can_delete_old_comments => false,
            :delete_replaces_content => false,
            :admin_can_edit_comments => false,
            :comment_posted_callback_name => '',
            :comment_edited_callback_name => '',
            :comment_deleted_callback_name => '',
            :subscribe_callback_name => '',
            :unsubscribe_callback_name => '',
            :commenter_name_method_name => '',
            :can_read_thread_method_name => '',
            :commentable_is_admin_method_name => '',
            :commenter_is_admin_method_name => ''
            }

module Commontator
  DEFAULTS.each do |key, value|
    mattr_accessor key
    self.send key.to_s + '=', value
  end
  
  def self.configure
    yield self
  end
end
