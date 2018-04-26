class LoadTestDataRemoverJob < ActiveJob::Base
  def perform(prisoner)
    prisoner.destroy
  end
end
