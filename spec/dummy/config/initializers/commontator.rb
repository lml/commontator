# Dummy application configuration file
Commontator.configure do |config|
  config.javascript_proc = ->(view) { '// Some javascript' }

  config.current_user_proc = ->(context) do
    user = context.current_user
    return user unless user.nil? && Rails.env.development?

    DummyUser.order(:created_at).first.tap do |user|
      user.can_read = true
      user.can_edit = true
      user.is_admin = true
    end
  end

  config.user_name_proc = ->(user) { user.try(:name) || 'Anonymous' }

  config.thread_read_proc = ->(thread, user) { user && user.can_read }

  config.thread_moderator_proc = ->(thread, user) { user.is_admin || user.can_edit }

  config.comment_voting = :ld

  config.comment_reply_style = :q

  config.comments_per_page = 10

  config.thread_subscription = :m

  config.mentions_enabled = true

  config.user_mentions_proc = ->(current_user, thread, query) do
    'DummyUser'.include?(query) ? DummyUser.all : DummyUser.none
  end
end
