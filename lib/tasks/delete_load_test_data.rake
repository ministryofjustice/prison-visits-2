namespace :load_test_data do
  desc 'Delete all the test data created by load tests'
  task delete: :environment do
    LoadTestDataRemover.run
    puts 'Load test data deleted'
  end
end
