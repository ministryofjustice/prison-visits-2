require 'rails_helper'
require 'mailers/shared_mailer_examples'

RSpec.describe VisitorMailer, '.booked' do
  let(:visit) { create(:booked_visit) }
  let!(:visitor) { create(:visitor, :banned, visit: visit, banned_until: banned_until) }
  let(:banned_until) { 3.days.from_now.to_date }
  let(:staff_response) do
    StaffResponse.new(visit: visit, user: create(:user))
  end
  let(:mail) { described_class.booked(staff_response.email_attrs, message_attributes) }
  let(:message_attributes) { nil }

  before do
    staff_response.valid?
    ActionMailer::Base.deliveries.clear
  end

  around do |example|
    travel_to Date.new(2015, 10, 1) do
      example.call
    end
  end

  include_examples 'template checks'

  it 'sends an email confirming the booking' do
    expect(mail.subject)
      .to match(/your visit for Monday 12 October has been confirmed/)
  end

  it 'uses the locale of the visit' do
    visit.locale = 'cy'
    expect(mail.subject)
      .to match(/mae eich ymweliad ar Dydd Llun 12 Hydref wedi'i gadarnhau/)
  end

  it 'notifies of the banned visitor' do
    expect(mail.html_part.body).to match("until #{banned_until.to_fs(:short_nomis)}")
  end

  context 'with an acceptance staff message' do
    let(:message_attributes) { attributes_for(:message).slice(:body) }

    it 'displays the message' do
      expect(mail.html_part.body).to match(message_attributes[:body])
    end
  end

  # TODO: Remove once Medway is on Prison Finder
  context 'when the prison is Medway Secure Training Centre' do
    let(:medway) { create(:estate, name: 'Medway Secure Training Centre') }
    let(:medway_prison) { create(:prison, estate: medway) }
    let(:visit) { create(:booked_visit, prison: medway_prison) }

    include_examples 'when the prison is not on prison finder'
  end
end
