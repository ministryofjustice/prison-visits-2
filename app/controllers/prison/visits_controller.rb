class Prison::VisitsController < ApplicationController
  helper CalendarHelper

  def edit
    @booking_response = BookingResponse.new(visit: visit)
  end

  def update
    @booking_response = BookingResponse.new(booking_response_params)
    if @booking_response.valid?
      BookingResponder.new(@booking_response).respond!
    else
      render :edit
    end
  end

private

  def visit
    Visit.find(params[:id])
  end

  def booking_response_params
    params.
      require(:booking_response).
      permit(
        :selection, :reference_no, :closed_visit,
        :allowance_will_renew, :allowance_renews_on,
        :privileged_allowance_available, :privileged_allowance_expires_on,
        :visitor_not_on_list, :visitor_banned
      ).
      merge(visit: visit)
  end
end
