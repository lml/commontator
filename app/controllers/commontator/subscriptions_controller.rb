module Commontator
  class SubscriptionsController < ApplicationController
    include ThreadsHelper
    
    before_filter :get_thread, :except => :index

    # GET /subscriptions
    def index
      @threads = Subscription.find_all_by_subscriber_id(@commontator.id)\
                             .collect { |cts| cts.thread }
    end

    # POST /1/subscribe
    def create
      raise SecurityTransgression unless @thread.can_subscribe?(@commontator)

      @thread.errors.add(:base, "You are already subscribed to this #{commontable_name(@thread)}") \
        unless @thread.subscribe(@commontator)

      respond_to do |format|
        format.html { redirect_to thread_url(thread) }
        format.js { render :subscribe }
      end

    end

    # POST /1/unsubscribe
    def destroy
      raise SecurityTransgression unless @thread.can_subscribe?(@commontator)

      @thread.errors.add(:base, "You are not subscribed to this #{commontable_name(@thread)}") \
        unless @thread.unsubscribe(@commontator)

      respond_to do |format|
        format.html { redirect_to thread_url(thread) }
        format.js { render :subscribe }
      end
    end
  end
end
