# frozen_string_literal: true
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

  def booked(attrs)
    visit = Visit.find(attrs[:visit_id])
    I18n.locale = visit.locale
    @message = visit.acceptance_message

    user = User.find_by(id: attrs[:user_id])
    @booking_response = BookingResponse.new(
      attrs.merge(visit: visit, user: user)
    )

    mail_visitor visit,
      date: format_date_without_year(@booking_response.slot_granted.begin_at)
  end

  def rejected(attrs)
    @visit = Visit.find(attrs.delete(:visit_id))
    I18n.locale = @visit.locale
    user = User.find_by(id: attrs.delete(:user_id))

    @booking_response = BookingResponse.new(
      attrs.merge(visit: @visit, user: user)
    )

    mail_visitor @visit,
      date: format_date_without_year(@visit.first_date)
  end

  def cancelled(visit)
    I18n.locale = visit.locale
    mail_visitor visit,
      prison_name: visit.prison_name,
      date: format_date_without_year(visit.date)
  end

  def one_off_message(message)
    @message = message
    I18n.locale = message.visit.locale

    mail_visitor message.visit,
      prison_name: message.visit.prison_name,
      date: format_date_without_year(message.visit.date)
  end

private

  def mail_visitor(visit, i18n_options = {})
    @visit = visit

    mail(
      from: I18n.t('mailer.noreply', domain: smtp_settings[:domain]),
      to:       visit.contact_email_address,
      reply_to: visit.prison_email_address,
      subject:  default_i18n_subject(i18n_options)
    )
  end
end
