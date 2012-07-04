module Commontator
  module ThreadsHelper    
    def commontable_name(thread)
      config = thread.config
      config.commontable_name.blank? ? \
      thread.commontable.class.name : \
      config.commontable_name
    end
    
    def commontable_id(thread)
      thread.commontable.send thread.config.commontable_id_method
    end
    
    def closer_name(thread)
      closer = thread.closer
      config = thread.config
      config.commontator_name_method.blank? ? 'Anonymous' :\
      closer.send config.commontator_name_method
    end
  
    def get_thread
      @thread = Thread.find(params[:id])
    end
  end
end
