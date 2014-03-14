require 'will_paginate/view_helpers/action_view'

module Commontator
  class RemoteLinkRenderer < WillPaginate::ActionView::LinkRenderer
    def link(text, target, attributes = {})
      attributes = attributes.merge('data-remote' => true)
      super(text, target, attributes)
    end
  end
end
