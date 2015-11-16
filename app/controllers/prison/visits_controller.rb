class Prison::VisitsController < ApplicationController
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
        :selection, :reference_no, :closed_visit, :vo_will_be_renewed,
        :pvo_possible, :visitor_not_on_list, :visitor_banned
      ).
      merge(visit: visit)
  end
end
