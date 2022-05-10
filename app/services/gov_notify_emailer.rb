require 'notifications/client'

class GovNotifyEmailer
  def initialize
    @client = Notifications::Client.new(ENV['GOV_NOTIFY_API_KEY'])
  end

  def send_email(visit, template_id)
    @client.send_email(
      email_address: visit.contact_email_address,
      template_id: template_id,
      personalisation: {
        visitor_first_name: visit.visitor_first_name,
        prison: visit.prison_name,
        prison_email_address: visit.prison_email_address
      }
    )
  end
end
