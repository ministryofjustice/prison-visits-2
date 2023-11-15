class Metrics::ProcessingState
  include ActiveModel::Model
  include ActiveModel::Serializers::JSON
  attr_accessor :date

  PROCESSING_STATES = %w[
    booked
    cancelled
    rejected
    requested
    withdrawn
  ].freeze

  attr_writer(*PROCESSING_STATES)

  PROCESSING_STATES.each do |processing_state|
    define_method processing_state do
      instance_variable_get("@#{processing_state}") || 0
    end
  end

  def attributes
    {
      date:,
      booked:,
      cancelled:,
      rejected:,
      requested:,
      withdrawn:
    }
  end
end
