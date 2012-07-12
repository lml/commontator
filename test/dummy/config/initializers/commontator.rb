# Change the settings below to suit your needs
# All settings are initially set to their default values
Commontator.configure do |config|

  # Engine Configuration

  # Method called on ApplicationController to return the current user
  # Default: 'current_user'
  config.current_user_method = 'current_user'

  # Proc that is called after any javascript runs (e.g. to clear flash)
  # It is passed the 'self' object from the view template, so you should be able to
  # access anything you normally could in a view template (by using, e.g. view.flash)
  # Should return a string containing JS to be appended to all Commontator JS responses
  # Default: lambda { |view| '$("#error_explanation").remove();' }
  config.javascript_proc = lambda { |view| '$("#error_explanation").remove();' }


  # Commontator (User model) Configuration

  # Whether the commontator's name is clickable in the comment view
  # Default: false
  config.commontator_name_clickable = false

  # The method that return the commontator's email address
  # Default: 'email'
  config.commontator_email_method = 'email'

  # The method that return the commontator's name
  # Default: '' (Anonymous)
  config.commontator_name_method = ''

  # Method that returns true if the commontator is an admin for all threads
  # Admins can always delete other users' comments and close threads
  # Default: '' (no admins)
  config.is_admin_method = ''


  # Commontable (Commentable model) Configuration

  # What a comment is called in your application
  # Default: 'comment'
  config.comment_name = 'comment'

  # Verb used when creating comments (present)
  # Default: 'post'
  config.comment_create_verb_present = 'post'

  # Verb used when creating comments (past)
  # Default: 'posted'
  config.comment_create_verb_past = 'posted'

  # What a commontable is called in your application
  # If you have multiple commontable models,
  # you might want to pass this configuration value
  # as an argument to acts_as_commontable in each one
  # Default: 'commontable'
  config.commontable_name = 'commontable'

  # Proc that returns the thread's view url (defaults to commontable's show url)
  # Main application's routes can be accessed using main_app object
  # Default: lambda { |main_app, thread| main_app.polymorphic_url(thread.commontable) }
  config.thread_url_proc = lambda { |main_app, thread| main_app.polymorphic_url(thread.commontable) }

  # Proc that returns the subscription email subject
  # Default:
  # lambda do |params|
  #   "#{params[:commontator_name]} #{params[:config].comment_create_verb_past} a " + \
  #   "#{params[:config].comment_name} on #{params[:commontable_name]} ##{params[:commontable_id]}"
  # end
  config.subscription_email_subject_proc = lambda do |params|
    "#{params[:commontator_name]} #{params[:config].comment_create_verb_past} a " + \
    "#{params[:config].comment_name} on #{params[:commontable_name]} ##{params[:commontable_id]}"
  end

  # The format of the timestamps used by Commontator
  # Default: '%b %d %Y, %I:%M %p'
  config.timestamp_format = '%b %d %Y, %I:%M %p'

  # Whether admins can edit other users' comments
  # Default: false
  config.admin_can_edit_comments = false

  # Whether users automatically subscribe to a thread when commenting
  # Default: false
  config.auto_subscribe_on_comment = false

  # Whether users can edit their own comments
  # Default: true
  config.can_edit_own_comments = true

  # Whether users can edit their own comments
  # after someone posted a newer comment
  # Default: false
  config.can_edit_old_comments = false

  # Whether users can delete their own comments
  # Default: false
  config.can_delete_own_comments = false

  # Whether users can delete their own comments
  # after someone posted a newer comment
  # Default: false
  config.can_delete_old_comments = false

  # Whether users can manually subscribe or unsubscribe to threads
  # Default: true
  config.can_subscribe_to_thread = true

  # Whether users can vote on other users' comments
  # Note: requires acts_as_votable gem installed
  # and configured for your application
  # Default: false
  config.comments_can_be_voted_on = false

  # Whether comments should be ordered by vote score
  # instead of by order posted
  # Default: false
  config.comments_ordered_by_votes = false

  # Whether users can read threads closed by admins
  # Default: true
  config.closed_threads_are_readable = true

  # Whether comments deleted by admins can be seen
  # (the content will still be hidden)
  # Default: true
  config.deleted_comments_are_visible = true

  # Method called on commontable to return its id
  # Default: 'id'
  config.commontable_id_method = 'id'

  # Method called on commontable and passed user as argument
  # If true, that user is a moderator for that particular commontable's thread
  # and is given admin-like capabilities for that thread only
  # Default: '' (no thread-specific moderators)
  config.can_edit_thread_method = ''

  # Method called on commontable and passed user as argument
  # If true, that user is allowed to read that commontable's thread
  # Default: '' (no read restrictions)
  config.can_read_thread_method = ''

  # Method called on commontable when a comment is created
  # Passed user, comment as arguments
  # Default: '' (no callback)
  config.comment_created_callback = ''

  # Method called on commontable when a comment is edited
  # Passed user, comment as arguments
  # Default: '' (no callback)
  config.comment_edited_callback = ''

  # Method called on commontable when a comment is deleted
  # Passed user, comment as arguments
  # Default: '' (no callback)
  config.comment_deleted_callback = ''

  # Method called on commontable when a thread is closed
  # Passed user as argument
  # Default: '' (no callback)
  config.thread_closed_callback = ''

  # Method called on commontable when a thread is subscribed to
  # Passed user as argument
  # Default: '' (no callback)
  config.subscribe_callback = ''

  # Method called on commontable when a thread is unsubscribed to
  # Passed user as argument
  # Default: '' (no callback)
  config.unsubscribe_callback = ''
end
