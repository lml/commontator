module Commontator
  module ActsAsCommontator
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    module ClassMethods
      def acts_as_commontator(options = {})
        # your code will go here
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
