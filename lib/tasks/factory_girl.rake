namespace :factory_girl do
  desc 'Verify that all FactoryGirl factories are valid'
  task lint: :environment do
    if Rails.env.test?
      begin
        DatabaseCleaner.start
        FactoryGirl.lint
      ensure
        DatabaseCleaner.clean
      end
    else
      sh 'rake db:environment:set[test] db:test:prepare factory_girl:lint'
    end
  end
end

task(:default).prerequisites.unshift task('factory_girl:lint')
