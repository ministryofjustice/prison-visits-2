class BookingResponder
  class Accept < BookingRequestProcessor
    def process_request(message = nil)
      super do
        visit.rejection = nil
        visit.accept!

        template_id = 'f63f6d5a-7c11-41f8-9110-ac9f47f19d6f'
        @gov_notify_email = GovNotifyEmailer.new
        @gov_notify_email.send_email(visit, template_id, nil, message)

        BookingResponse.successful
      end
    end
  end
end
