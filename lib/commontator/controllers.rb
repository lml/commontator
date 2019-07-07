require_relative 'shared_helper'

module Commontator::Controllers
  def self.included(base)
    base.helper Commontator::SharedHelper
  end

  def commontator_set_thread_variables
    return if @commontator_thread.nil? || !@commontator_thread.can_be_read_by?(@commontator_user)

    @commontator_per_page = params[:per_page]
    @commontator_per_page = @commontator_thread.config.comments_per_page \
      if @commontator_per_page.blank?
    @commontator_page = params[:page]
    @commontator_page = 1 if @commontator_page.blank?
    @commontator_show_all = !params[:show_all].blank? &&
                            @commontator_thread.can_be_edited_by?(@commontator_user)

    commontator_set_new_comment
  end

  def commontator_set_new_comment
    return unless @commontator_thread.config.new_comment_style == :t

    new_comment = Commontator::Comment.new(user: @commontator_user, thread: @commontator_thread)
    @commontator_new_comment = new_comment if new_comment.can_be_created_by?(@commontator_user)
  end

  def commontator_thread_show(commontable)
    commontator_set_user
    commontator_set_thread(commontable)
    commontator_set_thread_variables

    @commontator_thread_show = true
    @commontator_thread.mark_as_read_for(@commontator_user)
  end
end

ActionController::Base.send :include, Commontator::Controllers
