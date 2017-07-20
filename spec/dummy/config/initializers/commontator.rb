# Dummy application configuration file
Commontator.configure do |config|
  config.javascript_proc = lambda { |view| '// Some javascript' }

  config.user_name_proc = lambda { |user| user.try(:name) || 'Anonymous' }

  config.thread_read_proc = lambda { |thread, user| user && user.can_read }

  config.thread_moderator_proc = lambda { |thread, user| user.is_admin || user.can_edit }

  config.comment_voting = :ld

  config.thread_subscription = :m

  config.mentions_enabled = true

  config.user_mentions_proc = lambda { |current_user, thread, query|
    'DummyUser'.include?(query) ? DummyUser.all : DummyUser.none }
end

