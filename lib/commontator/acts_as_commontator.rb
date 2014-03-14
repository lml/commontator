require 'commontator/commontator_config'

module Commontator
  module ActsAsCommontator
    def self.included(base)
      base.class_attribute :is_commontator
      base.is_commontator = false
      base.extend(ClassMethods)
    end
    
    module ClassMethods
      def acts_as_commontator(options = {})
        class_eval do
          cattr_accessor :commontator_config
          self.commontator_config = Commontator::CommontatorConfig.new(options)
          self.is_commontator = true

          has_many :comments, :as => :commontator, :class_name => 'Commontator::Comment'

          has_many :subscriptions, :as => :subscriber, :class_name => 'Commontator::Subscription', :dependent => :destroy

          def commontator_name
            commontator_config.user_name_proc.call(self)
          end

          def commontator_email(mailer = nil)
            commontator_config.user_email_proc.call(self, mailer)
          end
          
          def commontator_link(main_app)
            commontator_config.user_link_proc.call(self, main_app)
          end
          
          def commontator_avatar(view_context)
            commontator_config.user_avatar_proc.call(self, view_context)
          end
        end
      end
      
      alias_method :acts_as_commonter, :acts_as_commontator
      alias_method :acts_as_commentator, :acts_as_commontator
      alias_method :acts_as_commenter, :acts_as_commontator
    end
  end
end

ActiveRecord::Base.send :include, Commontator::ActsAsCommontator
