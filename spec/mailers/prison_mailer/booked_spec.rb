require 'rails_helper'
require 'mailers/shared_mailer_examples'

RSpec.describe PrisonMailer, '.booked' do
  let(:visit) {
    create(
      :booked_visit,
      prisoner: create(
        :prisoner,
        first_name: 'Arthur',
        last_name: 'Raffles'
      )
    )
  }
  let(:mail) { described_class.booked(visit) }

  before do
    ActionMailer::Base.deliveries.clear
  end

  include_examples 'template checks'

  it 'sends an email confirming the booking' do
    expect(mail.subject).
      to match(/COPY of booking confirmation for Arthur Raffles/)
  end
end
