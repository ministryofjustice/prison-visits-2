module NoReply
  extend ActiveSupport::Concern

  def noreply_address
    "Prison Visits Booking (Unattended) <no-reply@#{smtp_domain}>"
  end

  included do
    default from: I18n.t('mailer.noreply', domain: smtp_settings[:domain])
  end
end
