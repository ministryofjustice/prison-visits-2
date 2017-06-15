class BookingResponse
  ALREADY_PROCESSED_ERROR = 'already_processed'.freeze
  PROCESS_REQUIRED_ERROR = 'process_required'.freeze
  NOMIS_VALIDATION_ERROR = 'nomis_validation_error'.freeze
  NOMIS_API_ERROR = 'nomis_api_error'.freeze
  SUCCESS = 'success'.freeze

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

  def initialize(message)
    self.message = message
  end

  def success?
    message == SUCCESS
  end

  def already_processed?
    message == ALREADY_PROCESSED_ERROR
  end

private

  attr_writer :message
end
