module Commontator
  class SubscriptionsController < ApplicationController
  
    include ThreadsHelper

    before_filter :get_thread, :except => :index

    # GET /subscriptions
    def index
      @threads = CommentThreadSubscription.find_all_by_subscriber_id(@user.id)\
                                          .collect { |cts| cts.thread }
    end

    # POST /1/subscribe
    def create
      raise SecurityTransgression unless @thread.can_subscribe?(@user)

      if !@thread.subscribe(@user)
        flash[:alert] = "You are already subscribed to this " + commontable_name(@thread)
      end

      respond_to do |format|
        format.html { redirect_to @thread }
        format.js
      end

    end

    # POST /1/unsubscribe
    def destroy
      raise SecurityTransgression unless @thread.can_subscribe?(@user)

      if !@thread.unsubscribe(@user)
        flash[:alert] = "You are not subscribed to this " + commontable_name(@thread)
      end

      respond_to do |format|
        format.html { redirect_to @thread }
        format.js
      end

    end

  end
end
