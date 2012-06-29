module Commontator
  module ActsAsCommontable
    included do
    end
    
    module ClassMethods
      def acts_as_commontable(options = {})
        class_eval do
          has_many :threads, :as => :commontable
          has_many :
        end
      end
      
      def acts_as_commentable(options = {})
        acts_as_commontable(options)
      end
    end
  end
end

ActiveRecord::Base.send :include, Commontator::ActsAsCommontable
