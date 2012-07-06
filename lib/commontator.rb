module Commontator
  # Attributes and default values

  # Can be overriden in initializer only
  ENGINE_CONFIG = {
    :current_user_method => 'current_user',
    :heading_function => '',
    :javascript_callback => ''
  }

  # Can be overriden in initializer and acts_as_commontator
  COMMONTATOR_CONFIG = {
    :commontator_name_clickable => false,
    :commontator_email_method => 'email',
    :commontator_name_method => '',
    :is_admin_method => ''
  }
  
  # Can be overriden in initializer and acts_as_commontable
  COMMONTABLE_CONFIG = {
    :comment_name => 'comment',
    :comment_create_verb_present => 'post',
    :comment_create_verb_past => 'posted',
    :commontable_name => 'commontable',
    :subscription_email_subject =>\
      'commontator_name(@comment) + @config.comment_create_verb_past' +\
      ' + " a " + @config.comment_name + " on " + commontable_name(@thread)' +\
      ' + " #" + commontable_id(@thread)',
    :subscription_email_body => '',
    :timestamp_format => '%b %d %Y, %I:%M %p',
    :admin_can_edit_comments => false,
    :auto_subscribe_on_comment => false,
    :can_edit_old_comments => false,
    :can_edit_own_comments => true,
    :can_delete_old_comments => false,
    :can_delete_own_comments => false,
    :can_subscribe_to_thread => true,
    :comments_can_be_voted_on => true,
    :closed_threads_are_readable => true,
    :deleted_comments_are_visible => true,
    :commontable_id_method => 'id',
    :can_edit_thread_method => '',
    :can_read_thread_method => '',
    :comment_created_callback => '',
    :comment_edited_callback => '',
    :comment_deleted_callback => '',
    :thread_closed_callback => '',
    :subscribe_callback => '',
    :unsubscribe_callback => ''
  }
  
  ENGINE_CONFIG.merge(COMMONTATOR_CONFIG.merge(\
    COMMONTABLE_CONFIG)).each do |key, value|
    mattr_accessor key
    self.send key.to_s + '=', value
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
