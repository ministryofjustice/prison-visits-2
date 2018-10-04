namespace :load_test_data do
  desc 'Delete all the test data created by load tests'
  task :delete, [:first_name, :last_name] => [:environment] do |_t, args|
    Rails.logger.info 'Starting load test data deletion'
    LoadTestDataRemover.delete_visits_created_by(args[:first_name], args[:last_name])
    Rails.logger.info 'Completed load test data deletion'
  end
end
