class DummyApiController < ActionController::API
  before_action :get_dummy

  def show
    commontator_thread_show(@dummy_model)
  end

  def url_options
    return Hash.new if request.nil?
    super
  end

  protected

  def get_dummy
    @dummy_model = DummyModel.find_by(id: params[:id]) || DummyModel.first
  end
end
