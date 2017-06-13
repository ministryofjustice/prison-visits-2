module StaffResponseContext
  extend ActiveSupport::Concern

private

  def load_visit
    @visit ||= scoped_visit
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
    visit = load_visit
    visit.assign_attributes(visit_params)
    BookingResponder.new(visit,
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
        allowance_renews_on: %i[day month year],
        reasons: []
      ],
      visitors_attributes:  [
        :id,
        :nomis_id,
        :banned,
        :not_on_list,
        banned_until: %i[day month year]
      ]
    )
  end
  # rubocop:enable Metrics/MethodLength

  def booking_responder_opts
    { validate_visitors_nomis_ready: params[:validate_visitors_nomis_ready] }
  end
end
