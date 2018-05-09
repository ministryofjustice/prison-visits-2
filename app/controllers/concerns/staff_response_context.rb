module StaffResponseContext
  extend ActiveSupport::Concern

  included do
    helper_method :nomis_checker,
      :prisoner_details,
      :nomis_info_presenter,
      :prisoner_location_presenter,
      :staff_response
  end

  def book_to_nomis_config
    @book_to_nomis_config ||=
      BookToNomisConfig.new(
        nomis_checker,
        memoised_visit.prison_name,
        params[:book_to_nomis_opted_in],
        @booking_response&.already_booked_in_nomis?,
        prisoner_details)
  end

  def nomis_checker
    @nomis_checker ||= StaffNomisChecker.new(memoised_visit)
  end

  def prisoner_details
    @prisoner_details ||= PrisonerDetailsPresenter.new(prisoner_validation)
  end

  def nomis_info_presenter
    @nomis_info_presenter ||= NomisInfoPresenter.new(
      prisoner_validation, prisoner_location_validation)
  end

  def prisoner_location_presenter
    @prisoner_location_presenter ||= PrisonerLocationPresenter.new(
      prisoner_location_validation)
  end

private

  def memoised_visit
    @memoised_visit ||= scoped_visit
  end

  def prisoner_validation
    @prisoner_validation ||= PrisonerValidation.new(nomis_checker.offender)
  end

  def prisoner_location_validation
    @prisoner_location_validation ||= PrisonerLocationValidation.new(
      nomis_checker.offender, memoised_visit.prison.nomis_id
    )
  end

  def message
    return unless params[:message]
    Message.new(
      body:    params[:message][:body],
      user_id: params[:message][:user_id]
    )
  end

  def scoped_visit
    Visit.joins(prison: :estate).
      where(estates: { id: accessible_estates }).
      find(visit_id_param)
  end

  def visit_id_param
    params[:id] || params[:visit_id]
  end

  def staff_response
    @staff_response ||= begin
      StaffResponse.new(
        visit: memoised_visit, user: current_user,
        validate_visitors_nomis_ready: params[:validate_visitors_nomis_ready])
    end
  end

  def booking_responder
    @booking_responder ||= BookingResponder.new(
      staff_response,
      message: message, options: booking_responder_opts)
  end

  # rubocop:disable Metrics/MethodLength
  def visit_params
    params.require(:visit).permit(
      :reference_no, :slot_granted, :closed, :slot_option_0,
      :slot_option_1, :slot_option_2, :prison_id, :prisoner_id,
      :principal_visitor_id, :processing_state, :id,
      visitor_ids: [],
      rejection_attributes: [
        'allowance_renews_on(1i)',
        'allowance_renews_on(2i)',
        'allowance_renews_on(3i)',
        :rejection_reason_detail,
        reasons: []
      ],
      visitors_attributes:  [
        :id,
        :nomis_id,
        :banned,
        :not_on_list,
        :other_rejection_reason,
        banned_until: [:day, :month, :year]
      ],
      prisoner_attributes: [:nomis_offender_id]
    )
  end
  # rubocop:enable Metrics/MethodLength

  def booking_responder_opts
    { persist_to_nomis: persist_to_nomis }
  end

  def persist_to_nomis
    params[:book_to_nomis_opted_in]
  end
end
