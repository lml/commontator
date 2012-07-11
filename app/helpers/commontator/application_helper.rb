module Commontator
  module ApplicationHelper
    def javascript_callback
      Commontator.javascript_proc.call.html_safe
    end
  end
end
