# Change the settings below to suit your needs
# All settings are initially set to their default values
Commontator.configure do |config|
  # Engine Configuration

  # Name of the ApplicationController helper method that returns the current user
  # Default: 'current_user'
  config.current_user_method = 'current_user'

  # Proc that is called after any javascript runs (e.g. to display/clear flash messages)
  # It is passed the view_context object (self from the view template), so you should be able to
  # access anything you normally could in a view template (by using, e.g. view.flash)
  # However, be aware that it does not have access to the main application's helpers
  # Should return a string containing JS to be appended to all Commontator JS responses
  # Default: lambda { |view| '$("#error_explanation").remove();' }
  config.javascript_proc = lambda { |view| '$("#error_explanation").remove();' }


  # User (acts_as_commontator) Configuration
  
  # The name used if the user's name cannot be retrieved
  # Default: 'Anonymous'
  config.user_missing_name = 'Anonymous'

  # Whether the comment creator's name is clickable in the comment view
  # If enabled, the link will point to the comment creator's 'show' page
  # Default: false
  config.user_name_clickable = false

  # The method that returns the user's email address
  # Default: 'email'
  config.user_email_method = 'email'

  # The method that returns the user's name
  # Default: '' (use user_missing_name)
  config.user_name_method = ''

  # Proc called with user as argument that returns true if the user is an admin
  # Admins can always delete other users' comments and close threads
  # Note: user can be nil
  # Default: lambda { |user| false } (no admins)
  config.user_admin_proc = lambda { |user| false }
  
  # Proc called with user as argument that returns true
  # if the user should receive subscription emails
  # Default: lambda { |user| true } (always receive subscription emails)
  config.subscription_email_enable_proc = lambda { |user| true }


  # Commontable (acts_as_commontable) Configuration

  # What a comment is called in your application
  # Default: 'comment'
  config.comment_name = 'comment'

  # Verb used when creating comments (present)
  # Default: 'post'
  config.comment_create_verb_present = 'post'

  # Verb used when creating comments (past)
  # Default: 'posted'
  config.comment_create_verb_past = 'posted'

  # Verb used when editing comments (present)
  # Default: 'modify'
  config.comment_edit_verb_present = 'modify'

  # Verb used when editing comments (past)
  # Default: 'modified'
  config.comment_edit_verb_past = 'modified'

  # What a commontable is called in your application
  # If you have multiple commontable models,
  # you will want to pass this configuration value
  # as an argument to acts_as_commontable in each one
  # Default: 'commontable'
  config.commontable_name = 'commontable'

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
  # Default: true
  config.can_delete_own_comments = true

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
  config.can_vote_on_comments = false

  # Whether comments should be ordered by vote score
  # instead of by order posted
  # Default: false
  config.comments_ordered_by_votes = false

  # Whether users can read threads closed by moderators
  # Default: true
  config.closed_threads_are_readable = true

  # Whether comments deleted by moderators can be seen
  # (the content will still be hidden)
  # Default: true
  config.deleted_comments_are_visible = true

  # The method which returns the commontable's id, sent to users in email messages
  # Default: 'id'
  config.commontable_id_method = 'id'

  # Proc called with thread and user as arguments
  # If it returns true, that user is a moderator for that particular thread
  # and is given admin-like capabilities for that thread only
  # Note: user can be nil
  # Default: lambda { |thread, user| false } (no thread-specific moderators)
  config.can_edit_thread_proc = lambda { |thread, user| false }

  # Proc called with thread and user as arguments
  # If it returns true, that user is allowed to read that thread
  # Note: user can be nil
  # Default: lambda { |thread, user| true } (no read restrictions)
  config.can_read_thread_proc = lambda { |thread, user| true }

  # Proc that returns the commontable url that contains the thread
  # (defaults to the commontable show url)
  # Main application's routes can be accessed using main_app object
  # Default: lambda { |main_app, commontable| main_app.polymorphic_url(commontable) }
  config.commontable_url_proc = lambda { |main_app, commontable| main_app.polymorphic_url(commontable) }
  
  # Proc that returns the subscription email 'from' address
  # Default:
  # lambda { |params| 'no-reply@example.com' }
  config.subscription_email_from_proc = lambda { |params| 'no-reply@example.com' }

  # Proc that returns the subscription email 'subject' string
  # Default:
  # lambda do |params|
  #   "#{params[:creator_name]} #{params[:config].comment_create_verb_past} a " + \
  #   "#{params[:config].comment_name} on #{params[:commontable_name]} #{params[:commontable_id]}"
  # end
  config.subscription_email_subject_proc = lambda do |params|
    "#{params[:creator_name]} #{params[:config].comment_create_verb_past} a " + \
    "#{params[:config].comment_name} on #{params[:commontable_name]} #{params[:commontable_id]}"
  end
end
