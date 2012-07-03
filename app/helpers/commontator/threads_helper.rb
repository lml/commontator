module Commontator
  module ThreadsHelper
    def get_thread
      @thread = Thread.find(params[:id])
    end
  end
end
