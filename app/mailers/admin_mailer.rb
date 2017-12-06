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

  def confirmed_bookings(email_address, dates_to_export = nil)
    exporter = WeeklyMetricsConfirmedCsvExporter.new(dates_to_export)

    attachments['confirmed_bookings.csv'] = {
      mime_type: 'text/csv',
      content: exporter.to_csv
    }

    mail(
      from: I18n.t('mailer.noreply', domain: smtp_settings[:domain]),
      to: email_address,
      subject: 'Confirmed bookings (CSV)'
    )
  end
end
