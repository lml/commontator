module Commontator
  module ApplicationHelper
    def heading(string)
      Commontator.heading_function.blank? ? \
      '<h1>'.html_safe + string + '</h1>'.html_safe : \
      send(Commontator.heading_function, string).html_safe
    end
    
    def javascript_callback
      Commontator.javascript_callback.blank? ? '' : send(Commontator.javascript_callback).html_safe
    end
  end
end
