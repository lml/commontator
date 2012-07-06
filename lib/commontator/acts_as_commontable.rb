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
          has_one :thread, :as => :commontable, :class_name => 'Commontator::Thread', :dependent => :destroy
          has_many :comments, :through => :thread
          has_many :subscriptions, :through => :thread
          has_many :subscribers, :through => :thread
          
          after_initialize :commontator_create_thread, :unless => :thread, :if => :id
          before_validation :build_thread, :unless => :thread
          
          validates_presence_of :thread
          
          cattr_accessor :commontable_config
          self.commontable_config = Commontator::CommontableConfig.new(options)
          self.is_commontable = true
          
          def commontator_create_thread
            self.thread = Commontator::Thread.new
            self.thread.commontable = self
            self.save!
          end
        end
      end
      
      def acts_as_commentable(options = {})
        acts_as_commontable(options)
      end
    end
  end
end

ActiveRecord::Base.send :include, Commontator::ActsAsCommontable
