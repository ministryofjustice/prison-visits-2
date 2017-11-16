class BookingResponse
  # Cancel visit return codes
  VISIT_NOT_FOUND           = 'visit_does_not_exist'.freeze
  VISIT_ALREADY_CANCELLED   = 'visit_already_cancelled'.freeze
  VISIT_COMPLETED           = 'visit_completed'.freeze
  INVALID_CANCELLATION_CODE = 'invalid_cancellation_code'.freeze

  # Book to Nomis return codes
  ALREADY_PROCESSED_ERROR       = 'already_processed'.freeze
  ALREADY_BOOKED_IN_NOMIS_ERROR = 'already_booked_in_nomis'.freeze
  PROCESS_REQUIRED_ERROR        = 'process_required'.freeze
  NOMIS_VALIDATION_ERROR        = 'nomis_validation_error'.freeze

  # Generic return codes
  NOMIS_API_ERROR = 'nomis_api_error'.freeze
  SUCCESS         = 'success'.freeze

  attr_reader :message

  def self.successful
    new(SUCCESS)
  end

  def self.process_required
    new(PROCESS_REQUIRED_ERROR)
  end

  def self.nomis_validation_error
    new(NOMIS_VALIDATION_ERROR)
  end

  def self.nomis_api_error
    new(NOMIS_API_ERROR)
  end

  def self.already_processed
    new(ALREADY_PROCESSED_ERROR)
  end

  def self.already_booked_in_nomis
    new(ALREADY_BOOKED_IN_NOMIS_ERROR)
  end

  def self.invalid_cancellation_code
    new(INVALID_CANCELLATION_CODE)
  end

  def self.visit_not_found
    new(VISIT_NOT_FOUND)
  end

  def self.visit_already_cancelled
    new(VISIT_ALREADY_CANCELLED)
  end

  def self.visit_completed
    new(VISIT_COMPLETED)
  end

  def initialize(message)
    self.message = message
  end

  def success?
    message == SUCCESS
  end

  def already_processed?
    message == ALREADY_PROCESSED_ERROR
  end

  def already_booked_in_nomis?
    message == ALREADY_BOOKED_IN_NOMIS_ERROR
  end

private

  attr_writer :message
end
