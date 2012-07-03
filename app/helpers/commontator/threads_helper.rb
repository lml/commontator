module Commontator
  module ThreadsHelper
    def commontable_name(thread)
      config = thread.config
      config.commontable_name.blank? ? \
      thread.commontable.class.name : \
      config.commontable_name
    end
  
    def get_thread
      @thread = Thread.find(params[:id])
    end
  end
end
