class BookingResponder
  class BookingRequestProcessor
    attr_reader :options

    def initialize(staff_response, options = {})
      self.staff_response = staff_response
      self.options = options
    end

    def process_request(message_for_visitor = nil)
      ActiveRecord::Base.transaction do
        self.booking_response = yield if block_given?
        raise ActiveRecord::Rollback unless booking_response.success?

        if message_for_visitor
          create_message(message_for_visitor, visit.last_visit_state)
        end

        record_creator
      end

      booking_response
    end

  private

    attr_accessor :staff_response, :booking_response
    attr_writer :options

    delegate :visit, to: :staff_response
    delegate :rejection, to: :visit

      # Remove following ignored rubocop once fix released for conflicting cops
    private :visit
    def record_creator
      visit.last_visit_state.update!(creator: staff_response.creator)
    end

    def create_message(message, visit_state_change)
      message.user_id ||= staff_response.user&.id
      return unless message.valid?

      message.update!(
        visit:,
        visit_state_change:
      )
    end
  end
end
