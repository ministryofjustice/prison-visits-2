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

  def booked(visit)
    @visit = visit

    mail_prison(visit, prisoner: visit.prisoner_full_name)
  end

  def rejected(visit)
    @visit = visit

    mail_prison(visit, prisoner: visit.prisoner_full_name)
  end

  def cancelled(visit)
    @visit = visit

    mark_this_highest_priority

    mail_prison(visit, cancelled_attributes(visit))
  end

private

  def mail_prison(visit, i18n_options = {})
    mail(
      from: I18n.t('mailer.noreply', domain: smtp_settings[:domain]),
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
end
