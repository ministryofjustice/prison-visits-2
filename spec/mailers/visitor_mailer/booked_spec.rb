require 'rails_helper'
require 'mailers/shared_mailer_examples'

RSpec.describe VisitorMailer, '.booked' do
  let(:visit) { create(:booked_visit) }
  let(:booking_response) do
    BookingResponse.new(visit: visit, user: create(:user), selection: BookingResponse::SLOTS.first)
  end
  let(:mail) { described_class.booked(booking_response.email_attrs) }

  before do
    ActionMailer::Base.deliveries.clear
  end

  around do |example|
    travel_to Date.new(2015, 10, 1) do
      example.call
    end
  end

  include_examples 'template checks'

  it 'sends an email confirming the booking' do
    expect(mail.subject).
      to match(/your visit for Monday 12 October has been confirmed/)
  end

  it 'uses the locale of the visit' do
    visit.update locale: 'cy'
    expect(mail.subject).
      to match(/mae eich ymweliad ar Dydd Llun 12 Hydref wedi'i gadarnhau/)
  end

  context 'with an acceptance staff message' do
    let(:message) { FactoryGirl.build_stubbed(:message) }

    before do
      expect(booking_response).
        to receive(:message_body).and_return(message.body)
    end

    it 'displays the message' do
      expect(mail.html_part.body).to match(message.body)
    end
  end
end
