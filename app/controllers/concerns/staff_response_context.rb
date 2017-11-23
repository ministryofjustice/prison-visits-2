module StaffResponseContext
  extend ActiveSupport::Concern

  def book_to_nomis_config
    @book_to_nomis_config ||=
      BookToNomisConfig.new(
        staff_nomis_checker,
        memoised_visit.prison_name,
        params[:book_to_nomis_opted_in],
        @booking_response&.already_booked_in_nomis?
      )
  end

private

  def memoised_visit
    @_visit ||= scoped_visit
  end

  def decorate_visit(visit)
    @_decorated_visit ||=
      visit.decorate(context: { staff_nomis_checker: staff_nomis_checker })
  end

  def staff_nomis_checker
    @staff_nomis_checker ||= StaffNomisChecker.new(memoised_visit)
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

  def booking_responder
    memoised_visit.assign_attributes(visit_params)

    BookingResponder.new(memoised_visit,
      user: current_user,
      message: message,
      options: booking_responder_opts)
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
        banned_until: [:day, :month, :year]
      ],
      prisoner_attributes: [:nomis_offender_id]
    )
  end
  # rubocop:enable Metrics/MethodLength

  def booking_responder_opts
    {
      validate_visitors_nomis_ready: params[:validate_visitors_nomis_ready],
      persist_to_nomis: persist_to_nomis
    }
  end

  def persist_to_nomis
    params[:book_to_nomis_opted_in]
  end
end
