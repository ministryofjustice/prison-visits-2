namespace :factory_bot do
  desc 'Verify that all FactoryBot factories are valid'
  task lint: :environment do
    if Rails.env.test?
      FactoryBot.lint
    else
      sh 'rake db:environment:set[test] db:test:prepare factory_bot:lint'
    end
  end
end
