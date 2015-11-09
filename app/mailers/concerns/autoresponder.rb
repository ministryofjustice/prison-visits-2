module Autoresponder
  include ActiveSupport::Concern

  def autorespond(parsed_email)
    mail(from: noreply_address,
         to: parsed_email.from.to_s,
         subject: 'This mailbox is not monitored')
  end
end
