# frozen_string_literal: true
class BookingResponder
  class BookingRequestProcessor
    def initialize(booking_response)
      @booking_response = booking_response
    end

    def process_request(message_for_visitor = nil)
      ActiveRecord::Base.transaction do
        yield if block_given?
        if message_for_visitor
          create_message(message_for_visitor, visit.last_visit_state)
        end

        record_visitor_or_user
      end
    end

  private

    attr_reader :booking_response

    delegate :visit, to: :booking_response
    delegate :rejection, to: :visit
    private :visit

    # Responses are either initiated by a user or visitor, but never both
    def record_visitor_or_user
      if booking_response.respond_to?(:user)
        visit.last_visit_state.update!(processed_by: booking_response.user)
      end

      if booking_response.respond_to?(:visitor)
        visit.last_visit_state.update!(visitor: booking_response.visitor)
      end
    end

    def create_message(message, visit_state_change)
      message.user_id ||= booking_response.user&.id
      return unless message.valid?

      message.update!(
        visit:              visit,
        visit_state_change: visit_state_change
      )
    end
  end
end
