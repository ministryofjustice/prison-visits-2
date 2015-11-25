class PrisonMailer < ActionMailer::Base
  include LogoAttachment
  include NoReply
  include DateHelper
  add_template_helper DateHelper
  add_template_helper LinksHelper

  layout 'email'

  attr_accessor :visit

  after_action :do_not_send_to_prison, if: :smoke_test?

  def request_received(visit)
    @visit = visit

    mail to: visit.prison_email_address,
         subject: default_i18n_subject(
           full_name: visit.prisoner_full_name,
           request_date: format_date_without_year(visit.slots.first.begin_at)
         )
  end

  def booked(visit)
    @visit = visit

    mail to: visit.prison_email_address,
         subject: default_i18n_subject(prisoner: visit.prisoner_full_name)
  end

  def rejected(visit)
    @visit = visit

    mail to: visit.prison_email_address,
         subject: default_i18n_subject(prisoner: visit.prisoner_full_name)
  end

  def cancelled(visit)
    @visit = visit

    mark_this_highest_priority
    mail(
      to: visit.prison_email_address,
      subject: default_i18n_subject(
        prisoner: visit.prisoner_full_name,
        date: format_date_without_year(visit.slots.first.begin_at),
        status: visit.processing_state.upcase
      )
    )
  end

private

  def smoke_test?
    visit && SmokeTestEmailCheck.new(visit.contact_email_address).matches?
  end

  def do_not_send_to_prison
    message.to = visit.contact_email_address
  end

  def mark_this_highest_priority
    headers('X-Priority' => '1 (Highest)', 'X-MSMail-Priority' => 'High')
  end
end
