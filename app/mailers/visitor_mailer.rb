class VisitorMailer < ActionMailer::Base
  include LogoAttachment
  include DateHelper
  add_template_helper DateHelper
  add_template_helper LinksHelper

  layout 'email'

  def request_acknowledged(visit)
    I18n.locale = visit.locale

    mail_visitor visit,
      receipt_date: format_date_without_year(visit.first_date)
  end

  def booked(visit)
    I18n.locale = visit.locale
    mail_visitor visit,
      date: format_date_without_year(visit.date)
  end

  def rejected(visit)
    I18n.locale = visit.locale
    mail_visitor visit,
      date: format_date_without_year(visit.first_date)
  end

  def cancelled(visit)
    I18n.locale = visit.locale
    mail_visitor visit,
      prison_name: visit.prison_name,
      date: format_date_without_year(visit.date)
  end

private

  def mail_visitor(visit, i18n_options = {})
    @visit = visit

    mail(
      from: I18n.t('mailer.noreply', domain: smtp_settings[:domain]),
      to: visit.contact_email_address,
      reply_to: visit.prison_email_address,
      subject: default_i18n_subject(i18n_options)
    )
  end
end
