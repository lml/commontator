class ApplicationController < ActionController::Base
  protect_from_forgery
  
  attr_accessor :current_user
end
