# Change the settings below to suit your needs
# All settings are initially set to their default values

# Note: Do not "return" from a Proc, use "next" instead if necessary
#       "return" in a lambda is OK
Commontator.configure do |config|
  # Engine Configuration

  # current_user_proc
  # Type: Proc
  # Arguments: the current controller (ActionController::Base)
  # Returns: the current user (acts_as_commontator)
  # The default works for Devise and similar authentication plugins
  # Default: lambda { |controller| controller.current_user }
  config.current_user_proc = lambda { |controller| controller.current_user }

  # javascript_proc
  # Type: Proc
  # Arguments: a view (ActionView::Base)
  # Returns: a String that is appended to Commontator JS views
  # Can be used, for example, to display/clear Rails error messages
  # Objects visible in view templates can be accessed
  # through the view object (for example, view.flash)
  # However, the view does not include the main application's helpers
  # Default: lambda { |view| '$("#error_explanation").remove();' }
  config.javascript_proc = lambda { |view|
                                    '$("#error_explanation").remove();' }



  # User (acts_as_commontator) Configuration

  # user_name_proc
  # Type: Proc
  # Arguments: a user (acts_as_commontator)
  # Returns: the user's name (String)
  # Default: lambda { |user| I18n.t('commontator.anonymous') } (all users are anonymous)
  config.user_name_proc = lambda { |user| I18n.t('commontator.anonymous') }

  # user_avatar_proc
  # Type: Proc
  # Arguments: a user (acts_as_commontator), a view (ActionView::Base)
  # Returns: a String containing a HTML <img> tag pointing to the user's avatar image
  # The commontator_gravatar_image_tag helper takes a user object,
  # a border size and an options hash for Gravatar, and produces a Gravatar image tag
  # See available options at http://en.gravatar.com/site/implement/images/)
  # Note: Gravatar has several security implications for your users
  #       It makes your users trackable across different sites and
  #       allows de-anonymization attacks against their email addresses
  #       If you absolutely want to keep users' email addresses or identities secret,
  #       do not use Gravatar or similar services
  # Default: lambda { |user, view|
  #            view.commontator_gravatar_image_tag(
  #              user, 1, :s => 60, :d => 'mm') }
  config.user_avatar_proc = lambda { |user, view|
                                     view.commontator_gravatar_image_tag(
                                       user, 1, :s => 60, :d => 'mm') }

  # user_email_proc
  # Type: Proc
  # Arguments: a user (acts_as_commontator), a mailer (ActionMailer::Base)
  # Returns: the user's email address (String)
  # The default works for Devise's defaults
  # If the mailer argument is nil, Commontator intends to hash the email and send the hash
  # to Gravatar, so you should always return the user's email address (if using Gravatar)
  # If the mailer argument is not nil, then Commontator intends to send an email to
  # the address returned; you can prevent it from being sent by returning a blank String
  # Default: lambda { |user, mailer| user.email }
  config.user_email_proc = lambda { |user, mailer| user.email }

  # user_link_proc
  # Type: Proc
  # Arguments: a user (acts_as_commontator),
  #            the app_routes (ActionDispatch::Routing::RoutesProxy)
  # Returns: a path to the user's `show` page (String)
  # If anything non-blank is returned, the user's name in comments
  # comments will become a hyperlink pointing to this path
  # The main application's routes can be accessed through the app_routes object
  # Default: lambda { |user, app_routes| '' } (no link)
  config.user_link_proc = lambda { |user, app_routes| '' }



  # Thread/Commontable (acts_as_commontable) Configuration

  # email_from_proc
  # Type: Proc
  # Arguments: a mailer (ActionMailer::Base)
  # Returns: the address emails are sent "from" (String)
  # Important: Change this to at least match your domain name
  # Default: lambda { |mailer|
  #          "no-reply@#{Rails.application.class.parent.to_s.downcase}.com" }
  config.email_from_proc = lambda { |mailer|
    "no-reply@#{Rails.application.class.parent.to_s.downcase}.com" }

  # thread_read_proc
  # Type: Proc
  # Arguments: a thread (Commontator::Thread), a user (acts_as_commontator)
  # Returns: a Boolean, true iif the user should be allowed to read that thread
  # Note: can be called with a user object that is false or nil (if they are not logged in)
  # Default: lambda { |thread, user| true } (anyone can read any thread)
  config.thread_read_proc = lambda { |thread, user| true }

  # thread_moderator_proc
  # Type: Proc
  # Arguments: a thread (Commontator::Thread), a user (acts_as_commontator)
  # Returns: a Boolean, true iif the user is a moderator for that thread
  # If you want global moderators, make this proc true for them regardless of thread
  # Default: lambda { |thread, user| false } (no moderators)
  config.thread_moderator_proc = lambda { |thread, user| false }

  # thread_subscription
  # Type: Symbol
  # Whether users can subscribe to threads to receive activity email notifications
  # Valid options:
  #   :n (no subscriptions)
  #   :a (automatically subscribe when you comment; cannot do it manually)
  #   :m (manual subscriptions only)
  #   :b (both automatic, when commenting, and manual)
  # Default: :m
  config.thread_subscription = :m

  # comment_voting
  # Type: Symbol
  # Whether users can vote on other users' comments
  # Valid options:
  #   :n (no voting)
  #   :l (likes - requires acts_as_votable gem)
  #   :ld (likes/dislikes - requires acts_as_votable gem)
  # Not yet implemented:
  #   :s (star ratings)
  #   :r (reputation system)
  # Default: :n
  config.comment_voting = :n

  # vote_count_proc
  # Type: Proc
  # Arguments: pos (Fixnum), neg (Fixnum)
  # Returns: vote count to be displayed (String)
  # pos is the number of likes, or the rating, or the reputation
  # neg is the number of dislikes, if applicable, or 0 otherwise
  # Default: lambda { |pos, neg| "%+d" % (pos - neg) }
  config.vote_count_proc = lambda { |pos, neg| "%+d" % (pos - neg) }

  # comment_order
  # Type: Symbol
  # What order to use for comments
  # Valid options:
  #   :e (earliest comment first)
  #   :l (latest comment first)
  #   :ve (highest voted first; earliest first if tied)
  #   :vl (highest voted first; latest first if tied)
  # Notes:
  #   :e is usually used in forums (discussions)
  #   :l is usually used in blogs (opinions)
  #   :ve and :vl are usually used where it makes sense to rate comments
  #     based on usefulness (q&a, reviews, guides, etc.)
  # If :l is selected, the "reply to thread" form will appear before the comments
  # Otherwise, it will appear after the comments
  # Default: :e
  config.comment_order = :e

  # comments_per_page
  # Type: Fixnum or nil
  # Number of comments to display in each page
  # Set to nil to disable pagination
  # Any other value requires the will_paginate gem
  # Default: nil (no pagination)
  config.comments_per_page = nil

  # wp_link_renderer_proc
  # Type: Proc
  # Arguments: a thread (Commontator::Thread)
  # Returns: a link renderer (WillPaginate::ActionView::LinkRenderer)
  # to be used for the given thread
  # Commontator supplies its own Commontator::RemoteLinkRenderer, which is
  # exactly like will_paginate's default, except it returns remote links
  # For more information, see:
  # https://github.com/mislav/will_paginate/wiki/Link-renderer
  # Default: lambda { |thread| Commontator::RemoteLinkRenderer }
  config.wp_link_renderer_proc = lambda { |thread|
                                          Commontator::RemoteLinkRenderer }

  # comment_editing
  # Type: Symbol
  # Whether users can edit their own comments
  # Valid options:
  #   :a (always)
  #   :l (only if it's the latest comment)
  #   :n (never)
  # Default: :l
  config.comment_editing = :l

  # comment_deletion
  # Type: Symbol
  # Whether users can delete their own comments
  # Valid options:
  #   :a (always)
  #   :l (only if it's the latest comment)
  #   :n (never)
  # Note: moderators can always delete any comment
  # Default: :l
  config.comment_deletion = :l

  # moderators_can_edit_comments
  # Type: Boolean
  # Whether moderators can edit other users' comments
  # Default: false
  config.moderators_can_edit_comments = false

  # hide_deleted_comments
  # Type: Boolean
  # Whether to hide deleted comments completely or show a placeholder
  # "deleted by" message that indicates when a comment was deleted
  # moderators will always see the comment with the placeholder message
  # the actual content will be hidden from all users with either option
  # Default: false (show placeholder message)
  config.hide_deleted_comments = false

  # hide_closed_threads
  # Type: Boolean
  # Whether to hide closed threads from normal users
  # moderators can always read closed threads
  # Default: false (normal users can still read closed threads)
  config.hide_closed_threads = false

  # commontable_name_proc
  # Type: Proc
  # Arguments: a commontable (acts_as_commontable)
  # Returns: a name that refers to the commontable object (String)
  # If you have multiple commontable models, you can also pass this
  # configuration value as an argument to acts_as_commontable for each one
  # Default: lambda { |commontable|
  #                   "#{commontable.class.name} ##{commontable.id}" }
  config.commontable_name_proc = lambda { |commontable|
    "#{commontable.class.name} ##{commontable.id}" }

  # commontable_url_proc
  # Type: Proc
  # Arguments: a commontable (acts_as_commontable),
  #            the app_routes (ActionDispatch::Routing::RoutesProxy)
  # Returns: a String containing the url of the view that
  #          calls commontator_thread for that object
  # This usually is the commontable's "show" page
  # The main application's routes can be accessed through the app_routes object
  # Default: lambda { |commontable, app_routes|
  #            app_routes.polymorphic_url(commontable) }
  # (defaults to the commontable's show url)
  config.commontable_url_proc = lambda { |commontable, app_routes|
    app_routes.polymorphic_url(commontable) }
end
