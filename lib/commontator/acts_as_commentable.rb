COMMENTABLE_ATTRIBUTES = [:comment_name,
                          :comment_create_verb_present,
                          :comment_create_verb_past,
                          :comment_update_verb_present,
                          :comment_updated_verb_past,
                          :subscription_email_subject,
                          :subscription_email_body,
                          :comments_can_be_voted_on,
                          :can_subscribe_to_thread,
                          :auto_subscribe_on_comment,
                          :admin_can_edit_comments,
                          :own_comments_can_be_edited,
                          :old_comments_can_be_edited,
                          :own_comments_can_be_deleted,
                          :old_comments_can_be_deleted,
                          :delete_replaces_content,
                          :comment_posted_callback_name,
                          :comment_edited_callback_name,
                          :comment_deleted_callback_name,
                          :subscribe_callback_name,
                          :unsubscribe_callback_name,
                          :can_read_thread_method_name,
                          :commentable_is_admin_method_name]

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
          
          COMMENTABLE_ATTRIBUTES.each do |attribute|
            cattr_accessor attribute
            self.send attribute.to_s + '=', options[attribute] || Commontator.send(attribute)
          end
        end
      end
      
      def acts_as_commontable(options = {})
        acts_as_commentable(options)
      end
    end
  end
end

ActiveRecord::Base.send :include, Commontator::ActsAsCommentable
