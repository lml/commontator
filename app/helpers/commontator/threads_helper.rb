module Commontator
  module ThreadsHelper
    def commontable_name(thread)
      thread.config.commontable_name_proc.call(thread.commontable)
    end
  end
end
