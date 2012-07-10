module Commontator
  module ApplicationHelper
    def heading(string)
      Commontator.heading_proc.call(string) unless Commontator.heading_proc.blank?
    end
    
    def javascript_callback
      Commontator.javascript_proc.call unless Commontator.javascript_proc.blank?
    end
  end
end
