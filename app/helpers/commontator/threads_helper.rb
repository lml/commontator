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
      user = thread.closer
      return Commontator.user_missing_name if user.nil?
      config = user.commontator_config
      config.user_name_method.blank? ? config.user_missing_name : \
        user.send(config.user_name_method)
    end
  end
end
