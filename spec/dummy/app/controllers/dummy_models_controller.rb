class DummyModelsController < ActionController::Base
  before_filter :get_dummy
  
  def hide
    render :show
  end
  
  def show
    commontator_thread_show(@dummy_model)
  end
  
  def url_options
    return Hash.new if request.nil?
    super
  end
  
  def view_context
    view_context = view_context_class.new
    view_context.view_paths = view_paths
    view_context.controller = self
    view_context
  end
  
  protected
  
  def get_dummy
    @dummy_model = DummyModel.find(params[:id])
  end
end
