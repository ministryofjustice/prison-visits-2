class BookingResponse
  def initialize(success:)
    @success = success
  end

  def success?
    @success
  end
end
