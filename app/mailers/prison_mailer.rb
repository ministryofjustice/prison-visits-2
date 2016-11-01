# frozen_string_literal: true
class PrisonMailer < ActionMailer::Base
  include LogoAttachment
  include DateHelper
  add_template_helper DateHelper
  add_template_helper LinksHelper

  layout 'email'

  attr_accessor :visit

  before_action :set_locale

  def request_received(visit)
    @visit = visit
    preferred_date = visit.slots.first.begin_at

    mail_prison(visit,
      full_name: visit.prisoner_full_name,
      request_date: format_date_without_year(preferred_date))
  end

  def booked(attrs)
    visit = Visit.find(attrs[:visit_id])
    user  = User.find_by(id: attrs[:user_id])
    @override_cancel_link = true
    @booking_response = BookingResponse.new(
      attrs.merge(visit: visit, user: user)
    )

    mail_prison(visit, prisoner: visit.prisoner_full_name)
  end

  def rejected(attrs)
    @visit = Visit.find(attrs.delete(:visit_id))
    I18n.locale = visit.locale
    user = User.find_by(id: attrs.delete(:user_id))

    @booking_response = BookingResponse.new(
      attrs.merge(visit: @visit, user: user)
    )

    mail_prison(@visit, prisoner: @visit.prisoner_full_name)
  end

  def cancelled(visit)
    @visit = visit

    mark_this_highest_priority

    mail_prison(visit, cancelled_attributes(visit))
  end

private

  def mail_prison(visit, i18n_options = {})
    return if skip_email?(visit)

    mail(
      from: I18n.t('mailer.noreply', domain: noreply_domain),
      to: visit.prison_email_address,
      subject: default_i18n_subject(i18n_options)
    )
  end

  def cancelled_attributes(visit)
    {
      prisoner: visit.prisoner_full_name,
      date: format_date_without_year(visit.slot_granted),
      status: visit.processing_state.upcase
    }
  end

  def mark_this_highest_priority
    headers('X-Priority' => '1 (Highest)', 'X-MSMail-Priority' => 'High')
  end

  def set_locale
    I18n.locale = I18n.default_locale
  end

  # The whitelabel settings in Sendgrid also means that the domain we use to
  # send emails gets set up to receive emails.
  def noreply_domain
    'robot.' + smtp_settings[:domain]
  end

  def skip_email?(visit)
    visit.prison.estate.name.in? Rails.configuration.dashboard_trial
  end
end
