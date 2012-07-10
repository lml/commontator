# Change the settings below to suit your needs
Commontator.configure do |config|
  config.current_user_method = 'current_user'
  config.heading_proc = nil
  config.javascript_proc = nil
  
  config.commontator_name_clickable = false
  config.commontator_email_method = 'email'
  config.commontator_name_method = ''
  config.is_admin_method = ''
  
  config.comment_name = 'comment'
  config.comment_create_verb_present = 'post'
  config.comment_create_verb_past = 'posted'
  config.commontable_name = 'commontable'
  config.subscription_email_subject_proc = Proc.new {|params| \
    "#{params[:commontator_name]} #{params[:config].comment_create_verb_past} a " + \
    "#{params[:config].comment_name} on #{params[:commontable_name]} ##{params[:commontable_id]}"}
  config.timestamp_format = '%b %d %Y, %I:%M %p'
  config.admin_can_edit_comments = false
  config.auto_subscribe_on_comment = false
  config.can_edit_own_comments = true
  config.can_edit_old_comments = false
  config.can_delete_own_comments = false
  config.can_delete_old_comments = false
  config.can_subscribe_to_thread = true
  config.comments_can_be_voted_on = false
  config.closed_threads_are_readable = true
  config.deleted_comments_are_visible = true
  config.commontable_id_method = 'id'
  config.can_edit_thread_method = ''
  config.can_read_thread_method = ''
  config.comment_created_callback = ''
  config.comment_edited_callback = ''
  config.comment_deleted_callback = ''
  config.thread_closed_callback = ''
  config.subscribe_callback = ''
  config.unsubscribe_callback = ''
end
