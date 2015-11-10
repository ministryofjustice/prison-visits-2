class PrisonMailer < ActionMailer::Base
  include LogoAttachment
  include DateHelper
  add_template_helper DateHelper

  layout 'email'
  default from: 'TODO'

  def request_received(visit)
    @visit = visit

    mail to: visit.prison_email_address,
         subject: default_i18n_subject(
           full_name: visit.prisoner_full_name,
           request_date: format_date_of_visit(visit.slots.first.begin_at)
         )
  end
end
