# Change the settings below to suit your needs
# All settings are initially set to their default values
Commontator.configure do |config|
  # Engine Configuration

  # Proc that is passed the current controller as argument
  # Returns the current user
  # Default: lambda { |controller| controller.current_user }
  config.current_user_proc = lambda { |controller| controller.current_user }

  # Proc called with the view_context object as argument
  # Returns a string to be appended to all JavaScript responses from commontator
  # Can be used, for example, to display/clear Rails error messages
  # Objects visible in view templates can be accessed through
  # the view_context object (for example, view_context.flash)
  # However, the view_context does not include the main application's helpers
  # Default: lambda { |view_context| '$("#error_explanation").remove();' }
  config.javascript_proc = lambda { |view_context| '$("#error_explanation").remove();' }


  # User (acts_as_commontator) Configuration

  # Whether the comment creator's name is clickable in the comment view
  # If enabled, the link will point to the comment creator's 'show' page
  # Default: false
  config.user_name_clickable = false

  # Proc called with user as argument
  # Returns the user's name
  # Default: lambda { |user| 'Anonymous' } (all users are Anonymous)
  config.user_name_proc = lambda { |user| 'Anonymous' }

  # Proc called with user as argument
  # Returns the user's email address
  # Used in the subscription mailer
  # Default: lambda { |user| user.email }
  config.user_email_proc = lambda { |user| user.email }

  # Proc called with user as argument
  # Returns true iif the user is an admin
  # Admins can delete other users' comments and close threads
  # Default: lambda { |user| false } (no admins)
  config.user_admin_proc = lambda { |user| false }
  
  # Proc called with user as argument
  # Returns true iif the user should receive subscription emails
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

  # The format of the timestamps used by Commontator
  # Default: '%b %d %Y at %I:%M %p'
  config.timestamp_format = '%b %d %Y at %I:%M %p'

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

  # What order to use for comments
  # Valid values:
  #   :e (earliest comment first)
  #   :l (latest comment first)
  #   :ve (highest voted first; earliest first if tied)
  #   :vl (highest voted first; latest first if tied)
  # Default: :e (earliest comment first)
  config.comments_order = :e

  # Whether users can read threads closed by moderators
  # Default: true
  config.closed_threads_are_readable = true

  # Whether to show that comments deleted by a moderator actually existed
  # (the content will be hidden either way)
  # Default: true
  config.deleted_comments_are_visible = true

  # Proc called with thread and user as arguments
  # Returns true iif the user should be allowed to read that thread
  # Note: can be called with a user object that is false or nil if not logged in
  # Default: lambda { |thread, user| true } (anyone can read threads even if not logged in)
  config.can_read_thread_proc = lambda { |thread, user| true }

  # Proc called with thread and user as arguments
  # Returns true iif the user is a moderator for that particular thread
  # and can delete users' comments in the thread or close it
  # Default: lambda { |thread, user| false } (no thread-specific moderators)
  config.can_edit_thread_proc = lambda { |thread, user| false }

  # Proc called with the commontable object as argument
  # Returns the name by which the commontable object will be called in email messages
  # If you have multiple commontable models, you may want to pass this
  # configuration value as an argument to acts_as_commontable in each one
  # Default: lambda { |commontable| "#{commontable.class.name} ##{commontable.id}" }
  config.commontable_name_proc = lambda { |commontable| "#{commontable.class.name} ##{commontable.id}" }

  # Proc called with main_app and commontable objects as arguments
  # Return the url that contains the commontable's thread to be used in the subscription email
  # The application's routes can be accessed using the main_app object
  # Default: lambda { |main_app, commontable| main_app.polymorphic_url(commontable) }
  # (defaults to the commontable's show url)
  config.commontable_url_proc = lambda { |main_app, commontable| main_app.polymorphic_url(commontable) }

  # Proc called with params from the subscription mailer as arguments
  # Returns the subscription email 'to' addresses
  # Available params can be seen in the subscription mailer
  # Note that the actual addresses are already set in the BCC field
  # Default:
  # lambda { |params| 'Undisclosed Recipients' }
  config.subscription_email_to_proc = lambda { |params| 'Undisclosed Recipients' }
  
  # Proc called with params from the subscription mailer as arguments
  # Returns the subscription email 'from' address
  # Available params can be seen in the subscription mailer
  # Default:
  # lambda { |params| 'no-reply@example.com' }
  config.subscription_email_from_proc = lambda { |params| 'no-reply@example.com' }

  # Proc called with params from the subscription mailer as arguments
  # Returns the subscription email 'subject' string
  # Available params can be seen in the subscription mailer
  # Default:
  # lambda do |params|
  #   "#{params[:creator_name]} #{params[:config].comment_create_verb_past} a " + \
  #   "#{params[:config].comment_name} on #{params[:commontable_name]}"
  # end
  config.subscription_email_subject_proc = lambda do |params|
    "#{params[:creator_name]} #{params[:config].comment_create_verb_past} a " + \
    "#{params[:config].comment_name} on #{params[:commontable_name]}"
  end
end
