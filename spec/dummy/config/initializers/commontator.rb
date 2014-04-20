# Dummy application configuration file
Commontator.configure do |config|
  config.javascript_proc = lambda { |view| '// Some javascript' }

  config.thread_read_proc = lambda { |thread, user| user && user.can_read }

  config.thread_moderator_proc = lambda { |thread, user| user.is_admin || user.can_edit }

  config.comment_voting = :ld

  config.thread_subscription = :m
end

