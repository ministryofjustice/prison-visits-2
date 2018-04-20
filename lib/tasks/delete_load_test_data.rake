namespace :load_test_data do
  desc 'Delete all the test data created by load tests'
  task delete: :environment do
    # We do not use rails env = staging?
    if Rails.env.staging?
      LoadTestDataRemover.run
      puts 'Load test data deleted'
    end
  end
end
