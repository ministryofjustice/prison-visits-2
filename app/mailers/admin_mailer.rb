class AdminMailer < ActionMailer::Base
  include LogoAttachment

  layout 'email'

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
