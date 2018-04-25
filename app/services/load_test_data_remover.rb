class LoadTestDataRemover
  # Warning! Do not run on production.
  # ENV['REMOVE_LOAD_TEST_DATA'] should be set to 'true' on Staging env only.
  def self.run
    delete_load_test_data if Rails.configuration.remove_load_test_data
  end

  class << self
  private

    ASSOCIATIONS = [
      :prisoner, :visitors, :visit_state_changes, :messages, :rejection, :cancellation
    ]

    def delete_load_test_data
      Visit.
        includes(ASSOCIATIONS).
        where(visitors: { first_name: 'Load', last_name: 'Test' }).
        find_in_batches(batch_size: 1000) do |batch|
          batch.each { |visit|  LoadTestDataRemoverJob.perform_later(visit.prisoner) }
        end
    end
  end
end
