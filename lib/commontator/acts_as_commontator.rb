module Commontator
  module ActsAsCommontator
    included do
    end
    
    module ClassMethods
      def acts_as_commontator(options = {})
        class_eval do
          has_many :comments, :as => :commenter
          has_many :subscriptions, :as => :subscriber
        end
      end
      
      def acts_as_commentator(options = {})
        acts_as_commontator(options)
      end
      
      def acts_as_commonter(options = {})
        acts_as_commontator(options)
      end
      
      def acts_as_commenter(options = {})
        acts_as_commontator(options)
      end
    end
  end
end

ActiveRecord::Base.send :include, Commontator::ActsAsCommontator
