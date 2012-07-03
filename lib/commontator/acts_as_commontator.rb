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
          has_many :comments, :as => :commontator, :dependent => :destroy
          has_many :subscriptions, :as => :subscriber, :dependent => :destroy
          
          cattr_accessor :commontator_config
          self.commontator_config = Commontator::CommontatorConfig.new(options)
          self.is_commontator = true
        end
      end
      
      def acts_as_commonter(options = {})
        acts_as_commontator(options)
      end
      
      def acts_as_commentator(options = {})
        acts_as_commontator(options)
      end
      
      def acts_as_commenter(options = {})
        acts_as_commontator(options)
      end
    end
  end
end

ActiveRecord::Base.send :include, Commontator::ActsAsCommontator
