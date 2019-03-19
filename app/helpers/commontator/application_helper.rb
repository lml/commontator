module Commontator
  module ApplicationHelper
    include LocalTimeHelper

    def javascript_proc
      Commontator.javascript_proc.call(self).html_safe
    end

    def created_timestamp comment
      t 'commontator.comment.status.created_at_html', :created_at => local_time_ago(comment.created_at)
    end

    def updated_timestamp comment
      t 'commontator.comment.status.updated_at_html',
        :editor_name => Commontator.commontator_name(comment.editor || comment.creator),
        :updated_at =>  local_time_ago(comment.updated_at)
    end
  end
end
