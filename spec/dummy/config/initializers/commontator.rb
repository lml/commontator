# Dummy application configuration file
Commontator.configure do |config|
  config.javascript_proc = lambda { |view_context| '// Some javascript' }

  config.user_admin_proc = lambda { |user| user.is_admin }

  config.can_vote_on_comments = true

  config.can_read_thread_proc = lambda { |thread, user| user && user.can_read }

  config.can_edit_thread_proc = lambda { |thread, user| user.can_edit }
end
