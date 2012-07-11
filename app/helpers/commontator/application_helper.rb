module Commontator
  module ApplicationHelper
    def javascript_callback
      Commontator.javascript_proc.call
    end
  end
end
