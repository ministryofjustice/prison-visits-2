module Autoresponder
  include ActiveSupport::Concern

  def autorespond(to)
    mail(to: to,
         subject: 'This mailbox is not monitored',
         template_path: 'shared_mailer',
         template_name: 'autorespond.txt')
  end
end
