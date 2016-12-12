module BookingResponseContext
  extend ActiveSupport::Concern

private

  def load_visit
    @visit ||= current_user ? scoped_visit : unscoped_visit
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
      where(estates: { id: current_estates }).
      find(visit_id_param)
  end

  def unscoped_visit
    Visit.find(visit_id_param)
  end

  def visit_id_param
    params[:id] || params[:visit_id]
  end

  # rubocop:disable Metrics/MethodLength
  def visit_params
    params.require(:visit).permit(
      :reference_no, :slot_granted, :closed, :slot_option_0,
      :slot_option_1, :slot_option_2, :prison_id, :prisoner_id,
      :principal_visitor_id, :processing_state, :id,
      visitor_ids: [],
      rejection_attributes: [
        allowance_renews_on: [:day, :month, :year],
        reasons: []
      ],
      visitors_attributes:  [
        :id,
        :banned,
        :not_on_list,
        banned_until: [:day, :month, :year]
      ]
    )
  end
  # rubocop:enable Metrics/MethodLength
end
