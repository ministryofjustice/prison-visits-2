class BookingResponder
  class VisitorCancel < BookingRequestProcessor
    def process_request
      super do
        visit.cancel!
        Cancellation.create!(visit: visit,
                             reasons: [Cancellation::VISITOR_CANCELLED],
                             nomis_cancelled: false)

        template_id = '12969e6f-96b4-40a6-994c-14432e604965'
        @cancellation = visit.cancellation.decorate

        begin
          @gov_notify_email = GovNotifyEmailer.new
          @gov_notify_email.send_email(visit, template_id)
        rescue Notifications::Client::AuthError
          pp 'auth error'
        end

        BookingResponse.successful
      end
    end
  end
end
