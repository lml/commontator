require 'commontator/commontable_config'

module Commontator
  module ActsAsCommontable
    def self.included(base)
      base.class_attribute :is_commontable
      base.is_commontable = false
      base.extend(ClassMethods)
    end
    
    module ClassMethods
      def acts_as_commontable(options = {})
        class_eval do
          has_one :thread, :as => :commontable, :class_name => 'Commontator::Thread'
          has_many :comments, :class_name => 'Commontator::Comment', :through => :thread
          has_many :subscriptions, :class_name => 'Commontator::Subscription', :through => :thread
          
          after_initialize :create_thread, :unless => :thread, :if => :id
          before_validation :build_thread, :unless => :thread
          
          validates_presence_of :thread
          
          cattr_accessor :commontable_config
          self.commontable_config = Commontator::CommontableConfig.new
          self.is_commontable = true
          
          def create_thread
            thread = Commontator::Thread.new
            thread.commontable = self
            thread.save!
            self.reload
          end
        end
      end
      
      alias_method :acts_as_commentable, :acts_as_commontable
    end
  end
end

ActiveRecord::Base.send :include, Commontator::ActsAsCommontable
