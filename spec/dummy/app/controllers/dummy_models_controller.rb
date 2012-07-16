class DummyModelsController < ActionController::Base
  before_filter :get_dummy
  
  def hide
    render :show
  end
  
  def show
    commontator_thread_show(@dummy)
  end
  
  protected
  
  def get_dummy
    @dummy = Dummy.find(params[:id])
  end
end
