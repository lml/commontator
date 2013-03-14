#!/usr/bin/env rake
begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

APP_RAKEFILE = File.expand_path("../spec/dummy/Rakefile", __FILE__)
load 'rails/tasks/engine.rake'

Bundler::GemHelper.install_tasks

require 'rake/testtask'

Rake::TestTask.new(:test => 'app:db:test:prepare') do |t|
  t.libs << 'lib'
  t.libs << 'spec'
  t.pattern = 'spec/**/*_spec.rb'
  t.verbose = false
end

task :default => :test

