module Commontator
  class CommentObserver < ActiveRecord::Observer
    def after_create(comment)
      thread = comment.thread
      thread.subscribe(comment.creator) if thread.config.auto_subscribe_on_comment
      thread.add_unread_except_for(comment.creator)
      recipients = thread.active_subscribers.reject{|s| s == comment.creator}
      SubscriptionsMailer.comment_created(comment, recipients).deliver \
        unless recipients.empty?
    end
  end
end
