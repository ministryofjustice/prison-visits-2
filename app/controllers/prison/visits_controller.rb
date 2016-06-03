class Prison::VisitsController < ApplicationController
  helper CalendarHelper
  before_action :authorize_prison_request

  def process_visit
    @booking_response = BookingResponse.new(visit: visit)

    unless @booking_response.processable?
      redirect_to prison_deprecated_visit_path(visit)
    end
  end

  def update
    @booking_response = BookingResponse.new(booking_response_params)
    if @booking_response.valid?
      @visit = @booking_response.visit
      BookingResponder.new(@booking_response).respond!
      redirect_to prison_deprecated_visit_path(@visit)
    else
      render :process_visit
    end
  end

  def deprecated_show
    @visit = visit
  end

  def show
    @visit = visit
    @estate = @visit.prison.estate
  end

  def cancel
    if visit.can_cancel?
      visit.staff_cancellation!(params[:cancellation_reason])
    end
    redirect_to prison_deprecated_visit_path(visit)
  end

private

  def visit
    Visit.find(params[:id])
  end

  def booking_response_params
    params.
      require(:booking_response).
      permit(
        :visitor_banned, :visitor_not_on_list,
        :selection, :reference_no, :closed_visit,
        :allowance_will_renew, :allowance_renews_on,
        :privileged_allowance_available, :privileged_allowance_expires_on,
        unlisted_visitor_ids: [], banned_visitor_ids: []
      ).
      merge(visit: visit)
  end
end
