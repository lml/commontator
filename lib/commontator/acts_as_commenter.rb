COMMENTER_ATTRIBUTES = [:commenter_is_admin_method_name,
                        :commenter_name_method_name,
                        :subscriber_email_method_name]

module Commontator
  module ActsAsCommenter
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    module ClassMethods
      def acts_as_commenter(options = {})
        class_eval do
          has_many :comments, :as => :commenter
          has_many :subscriptions, :as => :subscriber
          
          COMMENTER_ATTRIBUTES.each do |attribute|
            cattr_accessor attribute
            self.send attribute.to_s + '=', options[attribute] || Commontator.send(attribute)
          end
        end
      end
      
      def acts_as_commentator(options = {})
        acts_as_commenter(options)
      end
      
      def acts_as_commonter(options = {})
        acts_as_commenter(options)
      end
      
      def acts_as_commontator(options = {})
        acts_as_commenter(options)
      end
    end
  end
end

ActiveRecord::Base.send :include, Commontator::ActsAsCommenter
