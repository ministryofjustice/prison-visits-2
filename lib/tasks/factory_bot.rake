require 'database_cleaner'
require 'factory_bot'
require 'webmock'

namespace :factory_bot do
  desc 'Verify that all FactoryBot factories are valid'
  task lint: :environment do
    include WebMock::API

    WebMock.enable!
    WebMock.disable_net_connect!

    stub_request(:post, 'https://api.notifications.service.gov.uk/v2/notifications/email')
      .to_return(status: 200, body: '{}', headers: {})

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
