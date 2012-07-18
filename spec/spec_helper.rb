# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"

require "minitest/autorun"
require "minitest/rails"

Rails.backtrace_cleaner.remove_silencers!

Commontator::ApplicationController.class_eval do
  include ApplicationHelper
end

def setup_spec_variables
  @user = DummyUser.create
  @commontable = DummyModel.create
  @thread = @commontable.thread
end
