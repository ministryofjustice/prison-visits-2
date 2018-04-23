class LoadTestDataRemover
  # Warning! Do not run on production. ENV['REMOVE_LOAD_TEST_DATA']
  # should be set to 'true' on Staging env only.
  def self.run
    delete_load_test_data if Rails.configuration.remove_load_test_data
  end

  class << self
  private

    def delete_load_test_data
      visits = Visit.
        joins(:visitors).
        where("visitors.first_name = 'Load'").
        where("visitors.last_name = 'Test'")

      visits.each do |visit|
        visit.prisoner.destroy
      end

      visits.destroy_all
    end
  end
end
