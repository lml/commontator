module Commontator
  class SubscriptionsController < ApplicationController
    before_filter :get_thread

    # POST /1/subscribe
    def create
      raise SecurityTransgression unless @thread.can_subscribe?(@user)

      @thread.errors.add(:subscription, "You are already subscribed to this thread") \
        unless @thread.subscribe(@user)

      respond_to do |format|
        format.html { redirect_to @thread }
        format.js { render :subscribe }
      end

    end

    # POST /1/unsubscribe
    def destroy
      raise SecurityTransgression unless @thread.can_subscribe?(@user)

      @thread.errors.add(:subscription, "You are not subscribed to this thread") \
        unless @thread.unsubscribe(@user)

      respond_to do |format|
        format.html { redirect_to @thread }
        format.js { render :subscribe }
      end
    end
  end
end
