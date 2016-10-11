class BookingResponder
  class BookingRequestProcessor
    def initialize(booking_response)
      @booking_response = booking_response
    end

    def process_request
      ActiveRecord::Base.transaction do
        mark_disallowed_visitors

        yield if block_given?

        create_message(visit.last_visit_state)
        record_user(visit.last_visit_state)
      end
    end

  private

    attr_reader :booking_response

    delegate :visit, to: :booking_response
    private :visit

    def create_message(visit_state_change)
      return nil if booking_response.message_body.blank?

      Message.create!(
        body:               booking_response.message_body,
        user:               booking_response.user,
        visit:              visit,
        visit_state_change: visit_state_change
      )
    end

    def record_user(visit_state_change)
      visit_state_change.update!(processed_by: booking_response.user)
    end

    def mark_disallowed_visitors
      mark_unlisted_visitors
      mark_banned_visitors
    end

    def mark_unlisted_visitors
      visit.visitors.where(
        id: booking_response.unlisted_visitor_ids
      ).update_all not_on_list: true
    end

    def mark_banned_visitors
      visit.visitors.where(
        id: booking_response.banned_visitor_ids
      ).update_all banned: true
    end
  end
end
