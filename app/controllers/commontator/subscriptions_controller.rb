module Commontator
  class SubscriptionsController < ApplicationController
    before_filter :get_thread, :except => :index

    # POST /1/subscribe
    def create
      raise SecurityTransgression unless @thread.can_subscribe?(@commontator)

      @thread.errors.add(:base, "You are already subscribed to this thread") \
        unless @thread.subscribe(@commontator)

      respond_to do |format|
        format.html { redirect_to @commontable_url }
        format.js { render :subscribe }
      end

    end

    # POST /1/unsubscribe
    def destroy
      raise SecurityTransgression unless @thread.can_subscribe?(@commontator)

      @thread.errors.add(:base, "You are not subscribed to this thread") \
        unless @thread.unsubscribe(@commontator)

      respond_to do |format|
        format.html { redirect_to @commontable_url }
        format.js { render :subscribe }
      end
    end
  end
end
