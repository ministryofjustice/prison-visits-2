class BookingResponder
  class BookingRequestProcessor
    def initialize(staff_response)
      self.staff_response = staff_response
    end

    def process_request(message_for_visitor = nil)
      ActiveRecord::Base.transaction do
        self.booking_response = yield if block_given?

        if message_for_visitor
          create_message(message_for_visitor, visit.last_visit_state)
        end

        record_visitor_or_user
      end

      booking_response
    end

  private

    attr_accessor :staff_response, :booking_response

    delegate :visit, to: :staff_response
    delegate :rejection, to: :visit
    private :visit

    # Responses are either initiated by a user or visitor, but never both
    def record_visitor_or_user
      if staff_response.respond_to?(:user)
        visit.last_visit_state.update!(processed_by: staff_response.user)
      end

      if staff_response.respond_to?(:visitor)
        visit.last_visit_state.update!(visitor: staff_response.visitor)
      end
    end

    def create_message(message, visit_state_change)
      message.user_id ||= staff_response.user&.id
      return unless message.valid?

      message.update!(
        visit:              visit,
        visit_state_change: visit_state_change
      )
    end
  end
end
