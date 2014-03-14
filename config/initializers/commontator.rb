# Change the settings below to suit your needs
# All settings are initially set to their default values

# Note: Do not "return" from procs
#       Use "next" instead
Commontator.configure do |config|
  # Engine Configuration

  # Proc that is passed the current controller as argument
  # Returns the current user
  # Default: lambda { |controller| controller.current_user }
  config.current_user_proc = lambda { |controller| controller.current_user }

  # Proc called with the current view_context as argument
  # Returns a string to be appended to all JavaScript responses from Commontator
  # Can be used, for example, to display/clear Rails error messages
  # Objects visible in view templates can be accessed through
  # the view_context object (for example, view_context.flash)
  # However, the view_context does not include the main application's helpers
  # Default: lambda { |view_context| '$("#error_explanation").remove();' }
  config.javascript_proc = lambda { |view_context|
    '$("#error_explanation").remove();' }



  # User (acts_as_commontator) Configuration

  # Proc called with a user as argument
  # Returns the user's display name
  # Important: change this to return actual names or usernames
  # Default: lambda { |user| t('commontator.anonymous') } (all users are Anonymous)
  config.user_name_proc = lambda { |user| I18n.t('commontator.anonymous') }

  # Proc called with a user and the current view_context as arguments
  # Returns an HTML image tag containing the user's avatar image
  # The commontator_gravatar_image_tag helper takes a user object,
  # a border size, and an options hash for gravatar
  # See available options at http://en.gravatar.com/site/implement/images/)
  # Default: lambda { |user, view_context|
  #            view_context.commontator_gravatar_image_tag(
  #              user, 1, :s => 60, :d => 'mm') }
  config.user_avatar_proc = lambda { |user, view_context|
                              view_context.commontator_gravatar_image_tag(
                                user, 1, :s => 60, :d => 'mm') }

  # Proc called with a user and a mailer object as arguments
  # If the mailer argument is nil, the email is for internal use only and
  # this method should always return the user's email, no matter what
  # If the mailer argument is not nil, then an actual email will be sent to the
  # address returned; you can prevent it from being sent by checking the
  # arguments and returning a blank string, if appropriate
  # Default: lambda { |user, mailer| user.email }
  config.user_email_proc = lambda { |user, mailer| user.email }

  # Proc called with a user and the current view_context as arguments
  # Returns a link to the user's page
  # If anything non-blank is returned, the user's name in comments
  # will become a hyperlink pointing to this
  # The main application's routes can be accessed through the main_app object
  # Default: lambda { |user, main_app| '' } (no link)
  config.user_link_proc = lambda { |user, main_app| '' }



  # Thread/Commontable (acts_as_commontable) Configuration

  # Proc called with a mailer object as argument
  # Returns the address emails are sent 'from'
  # Important: Change this to at least match your domain name
  # Default: lambda { |mailer| 'no-reply@example.com' }
  config.email_from_proc = lambda { |mailer| 'no-reply@example.com' }

  # Proc called with a thread and a user as arguments
  # Returns true iif the user should be allowed to read that thread
  # Note: can be called with a user object that is false or nil if not logged in
  # Default: lambda { |thread, user| true } (anyone can read any thread)
  config.thread_read_proc = lambda { |thread, user| true }

  # Proc called with a thread and a user as arguments
  # Returns true iif the user is a moderator for that thread
  # Moderators can delete other users' comments and close threads
  # If you want global moderators, make this proc true for them
  # Note: moderators must "acts_as_commontator" too (like other users)
  # Default: lambda { |thread, user| false } (no moderators)
  config.thread_moderator_proc = lambda { |thread, user| false }

  # Whether users can subscribe to threads to receive activity email notifications
  # Valid options:
  #   :n (no subscriptions)
  #   :a (automatically subscribe when you comment; cannot do it manually)
  #   :m (manual subscriptions only)
  #   :b (both automatic, when commenting, and manual)
  # Default: :m
  config.thread_subscription = :m

  # Whether users can vote on other users' comments
  # Valid options:
  #   :n (no voting)
  #   :l (likes - requires acts_as_votable gem)
  #   :ld (likes/dislikes - requires acts_as_votable gem)
  # Not yet implemented:
  #   :s (star ratings)
  #   :r (reputation system)
  # Note: you can format how the votes are displayed by modifying the locale file
  # Default: :n
  config.comment_voting = :n

  # This proc is called with the value of config.comment_voting as an argument,
  # as well as pos and neg
  # pos is the number of likes or the rating or the reputation
  # neg is the number of dislikes, if applicable, or 0 otherwise
  # Returns the text to be displayed in between the voting buttons
  # Default: lambda { |comment_voting, pos, neg| "%+d" % (pos - neg) }
  config.voting_text_proc = lambda { |comment_voting, pos, neg|
                              "%+d" % (pos - neg) }

  # What order to use for comments
  # Valid options:
  #   :e (earliest comment first)
  #   :l (latest comment first)
  #   :ve (highest voted first; earliest first if tied)
  #   :vl (highest voted first; latest first if tied)
  # Default: :e
  config.comment_order = :e

  # Whether users can edit their own comments
  # Valid options:
  #   :a (always)
  #   :l (only if it's the latest comment)
  #   :n (never)
  # Default: :l
  config.comment_editing = :l

  # Whether users can delete their own comments
  # Valid options:
  #   :a (always)
  #   :l (only if it's the latest comment)
  #   :n (never)
  # Note: moderators can always delete any comment
  # Default: :l
  config.comment_deletion = :l

  # Whether moderators can edit other users' comments
  # Default: false
  config.moderators_can_edit_comments = false

  # Whether to hide deleted comments completely or show a placeholder message
  # that indicates when a comment was deleted in a thread
  # (moderators will always see the placeholder;
  # the content of the comment will be hidden from all users with either option)
  # Default: false (show placeholder message)
  config.hide_deleted_comments = false

  # If set to true, threads closed by moderators will be invisible to normal users
  # (moderators can still see them)
  # Default: false (normal users can still read closed threads)
  config.hide_closed_threads = false

  # Proc called with the commontable object as argument
  # Returns the name by which the commontable object will be called in email messages
  # If you have multiple commontable models, you may want to pass this
  # configuration value as an argument to acts_as_commontable in each one
  # Default: lambda { |commontable|
  #            "#{commontable.class.name} ##{commontable.id}" }
  config.commontable_name_proc = lambda { |commontable|
    "#{commontable.class.name} ##{commontable.id}" }

  # Proc called with main_app and a commontable object as arguments
  # Return the url that contains the commontable's thread (to be used in the subscription email)
  # The main application's routes can be accessed through the main_app object
  # Default: lambda { |commontable, main_app|
  #            main_app.polymorphic_url(commontable) }
  # (defaults to the commontable's show url)
  config.commontable_url_proc = lambda { |commontable, main_app|
    main_app.polymorphic_url(commontable) }
end
