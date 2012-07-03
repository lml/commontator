module Commontator
  module SubscriptionsHelper
    def email(subscriber)
      config = subscriber.commontator_config
      config.email_method.blank? ? '' : subscriber.send config.email_method
    end
  end
end
