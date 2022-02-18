require 'notifications/client'

class GovNotifyEmailer
  def initialize
    @client = Notifications::Client.new(ENV['GOV_NOTIFY_API_KEY'])
  end

  def send_email(email)
    @client.send_email(
      email_address: email,
      template_id: 'f63f6d5a-7c11-41f8-9110-ac9f47f19d6f',
      personalisation: {
        first_name: 'John Smith',
        prison_name: '2016',
        slot_granted: 'random',
        reference_number: 'random'
      }
    )
  end
end