require 'rails_helper'
require 'mailers/shared_mailer_examples'

RSpec.describe PrisonMailer, '.rejected' do
  let(:rejection) {
    create(
      :rejection,
      visit: create(
        :rejected_visit,
        prisoner: create(
          :prisoner,
          first_name: 'Arthur',
          last_name: 'Raffles'
        )
      )
    )
  }
  let(:visit) { rejection.visit }
  let(:booking_response) { BookingResponse.new(visit: visit) }
  let(:mail) { described_class.rejected(booking_response.email_attrs) }
  let(:body) { mail.html_part.body }

  before do
    ActionMailer::Base.deliveries.clear
  end

  include_examples 'template checks'
  include_examples 'noreply checks'
  include_examples 'skipping email for the trial'

  it 'sends an email reporting the rejection' do
    expect(mail.subject).
      to match(/COPY of booking rejection for Arthur Raffles/)
  end
end
