class VisitorMailer < ApplicationMailer
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

  def booked(attrs, message_attrs = nil)
    @visit = Visit.find(attrs['id'])
    @visit.assign_attributes(attrs)
    I18n.locale = @visit.locale

    if message_attrs
      @message = Message.new(message_attrs)
    end

    mail_visitor @visit,
                 date: format_date_without_year(@visit.slot_granted.begin_at)
  end

  def rejected(attrs, message_attrs = nil)
    @visit = Visit.find(attrs['id'])
    @visit.assign_attributes(attrs)

    # Loads the collection in memory we can
    # then have banned and unlisted visitors from the params
    @visit.visitors

    @rejection  = @visit.rejection.decorate
    I18n.locale = @visit.locale
    if message_attrs
      @message = Message.new(message_attrs)
    end

    mail_visitor @visit,
                 prison_name: @visit.prison_name
  end

  def cancelled(visit)
    I18n.locale = visit.locale

    @cancellation = visit.cancellation.decorate
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
      to: visit.contact_email_address,
      reply_to: visit.prison_email_address,
      subject: default_i18n_subject(i18n_options)
    )
  end
end
