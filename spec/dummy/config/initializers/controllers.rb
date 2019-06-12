ActionController::Base.class_exec do
  attr_accessor :current_user

  helper_method :current_user
end
