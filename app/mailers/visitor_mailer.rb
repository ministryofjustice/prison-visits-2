# -*- coding: utf-8 -*-
class VisitorMailer < ActionMailer::Base
  layout 'email'

  attr_reader :visit
  helper_method :visit

  default('List-Unsubscribe' => Rails.configuration.unsubscribe_url)

  def booking_receipt_email(visit, token)
    @visit = visit
    @token = token

    SpamAndBounceResets.new(@visit.visitors.first).perform_resets

    mail(
      from: sender,
      reply_to: prison_mailbox_email,
      to: recipient,
      subject: default_i18n_subject(
        receipt_date: format_date_of_visit(first_date)
      )
    )
  end

  def sender
    noreply_address
  end

  def recipient
    first_visitor_email
  end

  def first_date
    @visit.slots.first.date
  end

  def slot_date
    @slot.date
  end
end
