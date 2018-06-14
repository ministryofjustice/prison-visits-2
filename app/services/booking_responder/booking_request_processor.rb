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

        record_visitor_or_user
      end

      booking_response
    end

  private

    attr_accessor :staff_response, :booking_response
    attr_writer :options

    delegate :visit, to: :staff_response
    delegate :rejection, to: :visit

    # Remove following ignored rubocop once fix released for conflicting cops
    # rubocop:disable Style/AccessModifierDeclarations, Layout/AccessModifierIndentation
    private :visit
    # rubocop:enable Style/AccessModifierDeclarations, Layout/AccessModifierIndentation

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
