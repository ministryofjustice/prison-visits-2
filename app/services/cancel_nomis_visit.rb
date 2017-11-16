class CancelNomisVisit
  VISIT_NOT_FOUND           = 'Visit not found'.freeze
  VISIT_ALREADY_CANCELLED   = 'Visit already cancelled'.freeze
  VISIT_COMPLETED           = 'Visit completed'.freeze
  INVALID_CANCELLATION_CODE = 'Invalid or missing visit_id'.freeze

  NO_VO   = 'NO_VO'.freeze
  ADMIN   = 'ADMIN'.freeze
  OFFCANC = 'OFFCANC'.freeze

  def initialize(visit)
    self.visit     = visit
    self.api_error = false
  end

  def execute(params = {})
    params[:cancellation_code] = cancellation_code
    call_api(params)
    build_booking_response
  end

private

  attr_accessor :visit, :cancellation, :params, :api_error

  def call_api(params)
    self.cancellation =
      Nomis::Api.instance.cancel_visit(
        offender_id,
        visit.nomis_id,
        params: params
      )
  rescue Nomis::APIError
    self.api_error = true
  end

  def offender_id
    visit.prisoner.nomis_offender_id
  end

  def build_booking_response
    case
    when api_error                  then BookingResponse.nomis_api_error
    when visit_not_found?           then BookingResponse.visit_not_found
    when visit_already_cancelled?   then BookingResponse.visit_already_cancelled
    when visit_completed?           then BookingResponse.visit_completed
    when invalid_cancellation_code? then BookingResponse.invalid_cancellation_code
    else
      BookingResponse.successful
    end
  end

  def visit_not_found?
    cancellation.error_message == VISIT_NOT_FOUND
  end

  def visit_already_cancelled?
    cancellation.error_message == VISIT_ALREADY_CANCELLED
  end

  def visit_completed?
    cancellation.error_message == VISIT_COMPLETED
  end

  def invalid_cancellation_code?
    cancellation.error_message == INVALID_CANCELLATION_CODE
  end

  def cancellation_code
    if reasons.include?(Cancellation::PRISONER_VOS)
      NO_VO
    elsif reasons.include?(Cancellation::PRISONER_CANCELLED)
      OFFCANC
    else
      ADMIN
    end
  end

  def reasons
    visit.cancellation.reasons
  end
end
