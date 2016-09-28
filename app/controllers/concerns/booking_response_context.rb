module BookingResponseContext
  extend ActiveSupport::Concern

  def load_visit
    @visit ||= current_user ? scoped_visit : unscoped_visit
  end

  def scoped_visit
    Visit.joins(prison: :estate).
      where(estates: { id: current_estate }).
      find(visit_id_param)
  end

  def unscoped_visit
    Visit.find(visit_id_param)
  end

  def booking_response_params
    params.
      require(:booking_response).
      permit(
        :visitor_banned, :visitor_not_on_list, :selection, :reference_no,
        :allowance_will_renew, :privileged_allowance_available, :message_body,
        :closed_visit,
        allowance_renews_on: [:day, :month, :year],
        privileged_allowance_expires_on: [:day, :month, :year],
        unlisted_visitor_ids: [], banned_visitor_ids: []
      ).merge(visit: load_visit, user: current_user)
  end

  def visit_id_param
    params[:id] || params[:visit_id]
  end
end
