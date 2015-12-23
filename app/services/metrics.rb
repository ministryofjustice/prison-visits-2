class Metrics
  attr_accessor :prison, :visits

  def initialize(prison)
    @prison = prison
    @visits = prison.visits
  end

  def end_to_end_processing_time
    visits.average(:days_to_process)
  end
end
