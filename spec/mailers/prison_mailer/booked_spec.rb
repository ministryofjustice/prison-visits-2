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
  let(:booking_response) do
    BookingResponse.new(
      visit: visit, user: create(:user)
    )
  end

  let(:mail) { described_class.booked(booking_response.email_attrs) }

  before do
    booking_response.valid?
    ActionMailer::Base.deliveries.clear
  end

  include_examples 'template checks'
  include_examples 'noreply checks'
  include_examples 'skipping email for the trial'

  it 'sends an email confirming the booking' do
    expect(mail.subject).
      to match(/COPY of booking confirmation for Arthur Raffles/)
    expect(mail.body.encoded).to match(visit.prison.name)
  end

  it 'links to the prison visit show page' do
    expect(mail.body.encoded).to match(prison_visit_path(visit))
  end
end
