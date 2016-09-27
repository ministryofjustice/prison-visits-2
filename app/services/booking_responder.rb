class BookingResponder
  def initialize(booking_response)
    @booking_response = booking_response
  end

  def respond!
    return unless visit.requested?

    ActiveRecord::Base.transaction do
      mark_disallowed_visitors
      if booking_response.bookable?
        accept!
      else
        reject!
      end
    end

    send_emails
  end

private

  attr_reader :booking_response
  delegate :visit, to: :booking_response
  private :visit

  def accept!
    visit.accept!
    record_acceptance
  end

  def record_acceptance
    visit.update!(
      slot_granted: slot_granted,
      reference_no: booking_response.reference_no,
      closed: booking_response.closed_visit
    )

    last_visit_state = visit.last_visit_state
    create_message(last_visit_state)
    record_user(last_visit_state)
  end

  def reject!
    rejection = build_rejection(visit, booking_response)

    visit.reject!
    rejection.save!
    create_message(visit.last_visit_state)
    record_user(visit.last_visit_state)
  end

  def build_rejection(visit, booking_response)
    rejection = Rejection.new(visit: visit, reason: booking_response.reason)

    return rejection unless booking_response.no_allowance?

    if booking_response.allowance_will_renew?
      rejection.allowance_renews_on = booking_response.allowance_renews_on
    end

    if booking_response.privileged_allowance_available?
      rejection.privileged_allowance_expires_on =
        booking_response.privileged_allowance_expires_on
    end

    rejection
  end

  def notify_accepted
    VisitorMailer.booked(visit).deliver_later
    PrisonMailer.booked(visit).deliver_later
  end

  def notify_rejected
    VisitorMailer.rejected(visit).deliver_later
    PrisonMailer.rejected(visit).deliver_later
  end

  def mark_disallowed_visitors
    mark_unlisted_visitors if booking_response.unlisted_visitors.any?
    mark_banned_visitors if booking_response.banned_visitors.any?
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

  def create_message(visit_state_change)
    return nil if booking_response.message_body.blank?

    Message.create!(body: booking_response.message_body,
                    user: booking_response.user,
                    visit: visit,
                    visit_state_change: visit_state_change)
  end

  def record_user(visit_state_change)
    visit_state_change.update!(processed_by: booking_response.user)
  end

  def slot_granted
    visit.slots.fetch(booking_response.slot_index)
  end

  def send_emails
    case visit.processing_state
    when 'booked'
      notify_accepted
    when 'rejected'
      notify_rejected
    end
  end
end
