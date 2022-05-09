require 'notifications/client'

class GovNotifyEmailer
  def initialize
    @client = Notifications::Client.new(ENV['GOV_NOTIFY_API_KEY'])
  end

  def send_email(visit, prison)
    @client.send_email(
      email_address: visit.contact_email_address,
      template_id: 'f63f6d5a-7c11-41f8-9110-ac9f47f19d6f',
      personalisation: {
        first_name: 'John Smith',
        prison_name: prison.name,
        reference_number: visit.reference_no || '',
        slot_option_0: visit.slot_option_0 || '',
        slot_option_1:  visit.slot_option_1 || '',
        slot_option_2:  visit.slot_option_2 || ''
      }
    )
  end
end
