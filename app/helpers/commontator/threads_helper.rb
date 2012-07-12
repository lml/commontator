module Commontator
  module ThreadsHelper
    def commontable_name(thread)
      config = thread.config
      config.commontable_name.blank? ? \
      thread.commontable.class.name : \
      config.commontable_name
    end
    
    def commontable_id(thread)
      thread.commontable.send(thread.config.commontable_id_method)
    end
    
    def closer_name(thread)
      closer = thread.closer
      config = closer.commontator_config
      config.commontator_name_method.blank? ? config.anonymous_name : \
      closer.send(config.commontator_name_method)
    end
  end
end
