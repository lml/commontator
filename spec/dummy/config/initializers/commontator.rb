# Dummy application configuration file
Commontator.configure do |config|
  config.javascript_proc = ->(view) { '// Some javascript' }

  config.current_user_proc = ->(context) do
    user = context.current_user
    return user unless user.nil? && Rails.env.development?

    DummyUser.order(:created_at).last.tap do |user|
      user.can_read = true
      user.can_edit = true
      user.is_admin = true
    end
  end

  config.user_name_proc = ->(user) { user.try(:name) || 'Anonymous' }

  config.user_avatar_proc = ->(user, view) do
    view.commontator_gravatar_image_tag(user, 1, s: 60, d: 'mm')
  end

  config.thread_read_proc = ->(thread, user) { user && user.can_read }

  config.thread_moderator_proc = ->(thread, user) { user.is_admin || user.can_edit }

  config.comment_voting = :ld

  config.comment_reply_style = :q

  config.thread_subscription = :b

  config.mentions_enabled = true

  config.user_mentions_proc = ->(current_user, thread, query) do
    'DummyUser'.include?(query) ? DummyUser.all : DummyUser.none
  end

  config.comment_filter = Commontator::Comment.arel_table[:body].does_not_match('%hidden%')
end
