require_relative 'commontable_config'

module Commontator::ActsAsCommontable
  def self.included(base)
    base.class_attribute :is_commontable
    base.is_commontable = false
    base.extend(ClassMethods)
  end

  module ClassMethods
    def acts_as_commontable(options = {})
      class_exec do
        cattr_accessor :commontable_config
        association_options = options.extract!(:dependent)
        self.commontable_config = Commontator::CommontableConfig.new(options)
        self.is_commontable = true

        has_one :commontator_thread, as: :commontable,
                                     class_name: 'Commontator::Thread',
                                     dependent: association_options[:dependent]

        validates :commontator_thread, presence: true

        prepend ThreadWithCommontator
      end
    end

    module ThreadWithCommontator
      def commontator_thread
        @commontator_thread ||= super
        return @commontator_thread unless @commontator_thread.nil?

        @commontator_thread = build_commontator_thread.tap do |thread|
          thread.save if persisted?
        end
      end
    end

    alias_method :acts_as_commentable, :acts_as_commontable
  end
end

ActiveRecord::Base.send :include, Commontator::ActsAsCommontable
