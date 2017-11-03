RSpec::Matchers.define :receive_email do
  match do |address|
    emails =
      ActionMailer::Base.deliveries.select { |e| e.to.include?(address) }

    emails.select! { |e| e.subject.match(subject) } if subject
    emails.select! { |e| body_matches?(e, body) } if body
    emails.select! { |e| attachment_match?(e, attachment) } if attachment

    emails.any?
  end

  chain :with_subject, :subject
  chain :with_body, :body
  chain :and_body, :body
  chain :with_attachment, :attachment

  def body_matches?(email, pattern)
    email.text_part.body.to_s.gsub(/\s+/, ' ').match(pattern)
  end

  def attachment_match?(email, filename)
    email.attachments.any? { |e| e.filename == filename }
  end
end
