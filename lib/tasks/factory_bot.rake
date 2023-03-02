require 'database_cleaner'
require 'factory_bot'

namespace :factory_bot do
  desc 'Verify that all FactoryBot factories are valid'
  task lint: :environment do
    if Rails.env.test?
      begin
        DatabaseCleaner.start
        FactoryBot.lint
      ensure
        DatabaseCleaner.clean
      end
    else
      sh 'rake db:environment:set[test] db:test:prepare factory_bot:lint'
    end
  end
end

task(default: :environment).prerequisites.unshift task('factory_bot:lint': :environment)
