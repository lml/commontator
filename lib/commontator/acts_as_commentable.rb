module Commontator
  module ActsAsCommentable
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    module ClassMethods
      def acts_as_commentable(options = {})
        class_eval do
          has_one :thread, :as => :commentable
          has_many :comments, :through => :thread
          has_many :subscriptions, :through => :thread
          has_many :subscribers, :through => :thread
        end
      end
      
      def acts_as_commontable(options = {})
        acts_as_commentable(options)
      end
    end
  end
end

ActiveRecord::Base.send :include, Commontator::ActsAsCommentable
