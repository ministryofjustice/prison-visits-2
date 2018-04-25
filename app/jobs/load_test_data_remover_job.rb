class LoadTestDataRemoverJob < ActiveJob::Base
  queue_as :load_testing

  def perform(prisoner)
    prisoner.destroy
  end
end
