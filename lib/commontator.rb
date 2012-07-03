module Commontator
  # Attributes and default values

  # Can be overriden in initializer only
  ENGINE_CONFIG = {
    :current_user_method => 'current_user'
  }

  # Can be overriden in initializer and acts_as_commontator
  COMMONTATOR_CONFIG = {
    :name_method => 'name',
    :email_method => 'email',
    :is_admin_method => ''
  }
  
  # Can be overriden in initializer and acts_as_commontable
  COMMONTABLE_CONFIG = {
    :commontable_name => '',
    :comment_name => 'comment',
    :comment_create_verb_present => 'post',
    :comment_create_verb_past => 'posted',
    :comment_update_verb_present => 'edit',
    :comment_update_verb_past => 'edited',
    :timestamp_format => '%b %d %Y, %I:%M %p',
    :subscription_email_subject => '#{@commontator.send name_method_name} posted on Thread ##{@thread.id}',
    :subscription_email_body => \
      '#{@commontator.send name_method_name} posted on Thread ##{@thread.id}<br/><br/>
      Click <a href="#{thread_path(@thread)}">here</a> to visit the thread.<br/><br/>
      If you wish to unsubscribe from this thread, click <a href="#{unsubscribe_thread_path(@thread)}">here</a>.',
    :comments_can_be_voted_on => true,
    :can_subscribe_to_thread => true,
    :auto_subscribe_on_comment => false,
    :can_edit_own_comments => true,
    :can_edit_old_comments => false,
    :can_delete_own_comments => false,
    :can_delete_old_comments => false,
    :delete_replaces_content => false,
    :admin_can_edit_comments => false,
    :can_read_thread_method => '',
    :can_edit_thread_method => '',
    :comment_posted_callback => '',
    :comment_edited_callback => '',
    :comment_deleted_callback => '',
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
require 'commontator/routes'
require 'commontator/commontator_config'
require 'commontator/commontable_config'
require 'commontator/acts_as_commontator'
require 'commontator/acts_as_commontable'
