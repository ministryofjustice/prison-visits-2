class VisitorMailer < ActionMailer::Base
  include LogoAttachment
  include NoReply
  include DateHelper
  add_template_helper DateHelper

  layout 'email'

  attr_reader :visit

  def request_acknowledged(visit)
    @visit = visit

    # SpamAndBounceResets.new(@visit.visitors.first).perform_resets

    mail(
      from: noreply_address,
      reply_to: prison_email,
      to: recipient,
      subject: default_i18n_subject(
        receipt_date: format_date_of_visit(first_date)
      )
    )
  end

  delegate :recipient, :prison_email, :first_date, to: :visit
end
