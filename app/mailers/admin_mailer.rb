class AdminMailer < ActionMailer::Base
  include LogoAttachment

  layout 'email'

  def slot_availability(availability)
    @availability = availability

    mail(
      from: I18n.t('mailer.noreply', domain: smtp_settings[:domain]),
      to: Rails.configuration.pvb_team_email,
      subject: "Slot availability - #{Time.zone.today}"
    )
  end
end
