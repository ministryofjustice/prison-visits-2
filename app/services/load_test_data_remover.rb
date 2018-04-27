class LoadTestDataRemover
  # Warning! Do not run on production.
  # ENV['REMOVE_LOAD_TEST_DATA'] should be set to 'true' on Staging env only.
  def self.delete_visits_created_by(first_name, last_name)
    run(first_name, last_name) if Rails.configuration.remove_load_test_data
  end

  class << self
  private

    ASSOCIATIONS = [
      :prisoner, :visitors, :visit_state_changes, :messages, :rejection, :cancellation
    ]

    def run(first_name, last_name)
      Visit.
        includes(ASSOCIATIONS).
        where(visitors: { first_name: first_name, last_name: last_name }).
        find_in_batches(batch_size: 50) do |batch|
          batch.each do |visit|
            LoadTestDataRemoverJob.perform_later(visit.prisoner)
          end
        end
    end
  end
end
