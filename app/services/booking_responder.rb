class BookingResponder
  def initialize(booking_response)
    @booking_response = booking_response
  end

  def respond!
    mark_disallowed_visitors
    if booking_response.bookable?
      accept!
    else
      reject!
    end
  end

private

  attr_reader :booking_response
  delegate :visit, to: :booking_response
  private :visit

  def accept!
    ActiveRecord::Base.transaction do
      visit.accept!
      visit.update!(
        slot_granted: visit.slots.fetch(booking_response.slot_index),
        reference_no: booking_response.reference_no,
        closed: booking_response.closed_visit
      )
    end

    notify_accepted visit
  end

  def reject!
    return if visit.rejected?

    rejection = Rejection.new(visit: visit, reason: booking_response.reason)
    copy_no_allowance_parameters(rejection)

    ActiveRecord::Base.transaction do
      visit.reject!
      rejection.save!
    end

    notify_rejected visit
  end

  def copy_no_allowance_parameters(rejection)
    return unless booking_response.no_allowance?

    if booking_response.allowance_will_renew?
      rejection.allowance_renews_on = booking_response.allowance_renews_on
    end

    if booking_response.privileged_allowance_available?
      rejection.privileged_allowance_expires_on =
        booking_response.privileged_allowance_expires_on
    end
  end

  def notify_accepted(visit)
    VisitorMailer.booked(visit).deliver_later
    PrisonMailer.booked(visit).deliver_later
  end

  def notify_rejected(visit)
    VisitorMailer.rejected(visit).deliver_later
    PrisonMailer.rejected(visit).deliver_later
  end

  def mark_disallowed_visitors
    mark_unlisted_visitors if booking_response.visitor_not_on_list?
    mark_banned_visitors if booking_response.visitor_banned?
  end

  def mark_unlisted_visitors
    booking_response.unlisted_visitors.each do |visitor|
      visitor.update! not_on_list: true
    end
  end

  def mark_banned_visitors
    booking_response.banned_visitors.each do |visitor|
      visitor.update! banned: true
    end
  end
end
