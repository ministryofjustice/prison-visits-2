require File.expand_path('../config/application', __FILE__)

Rails.application.load_tasks
task :default do
  Rake::Task['spec'].invoke
  Rake::Task['jasmine:ci'].invoke
end
