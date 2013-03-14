# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)

require "minitest/autorun"
require "minitest/rails"

Rails.backtrace_cleaner.remove_silencers!

Commontator::ApplicationController.class_eval do
  include ApplicationHelper
end

def setup_model_spec
  @user = DummyUser.create
  @commontable = DummyModel.create
  @thread = @commontable.thread
end

def setup_controller_spec
  class_eval {include ApplicationHelper}
  sign_out
  setup_model_spec
end

def setup_helper_spec
  setup_model_spec
end

def setup_mailer_spec
  setup_model_spec
end
