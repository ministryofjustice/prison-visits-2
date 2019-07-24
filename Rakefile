require File.expand_path('../config/application', __FILE__)
require 'turnout/rake_tasks'

Rails.application.load_tasks
task :default do
  Rake::Task['spec'].invoke
  Rake::Task['jasmine:ci'].invoke
end
