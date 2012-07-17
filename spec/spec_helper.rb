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
