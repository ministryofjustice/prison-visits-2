require 'rails_helper'
require 'mailers/shared_mailer_examples'

RSpec.describe VisitorMailer, '.cancelled' do
  let(:visit) { create(:cancelled_visit) }
  let(:mail) { described_class.cancelled(visit) }
  let(:reason) { 'slot_unavailable' }

  before do
    ActionMailer::Base.deliveries.clear
    FactoryGirl.create(:cancellation, visit: visit, reason: reason)
  end

  around do |example|
    travel_to Date.new(2015, 10, 1) do
      example.call
    end
  end

  include_examples 'template checks'

  it 'sends an email notifying of the visit cancellation' do
    prison_name = visit.prison_name
    expect(mail.subject).
      to match(
        /CANCELLED: Your #{prison_name} prison visit for Monday 12 October/)
  end

  context 'when the slot is no longer available' do
    let(:reason) { 'slot_unavailable' }

    it { expect(mail.html_part.body).to match(/no longer available/) }
  end

  context 'when the prisoner has moved' do
    let(:reason) { 'prisoner_moved' }

    it { expect(mail.html_part.body).to match(/has now moved/) }
  end

  context 'when the visitor is banned' do
    let(:reason) { 'visitor_banned' }

    it { expect(mail.html_part.body).to match(/A letter has been sent/) }
  end

  context 'when the prisoner has no vos' do
    let(:reason) { 'prisoner_vos' }

    it { expect(mail.html_part.body).to match(/no visiting allowance/) }
  end

  context 'when the prisoner has been released' do
    let(:reason) { 'prisoner_released' }

    it { expect(mail.html_part.body).to match(/has been released/) }
  end

  context 'when there are capacity issues' do
    let(:reason) { 'capacity_issues' }

    it { expect(mail.html_part.body).to match(/capacity issues/) }
  end

  context 'when there are child protection issues' do
    let(:reason) { 'child_protection_issues' }

    it { expect(mail.html_part.body).to match(/is now restricted/) }
  end

  context 'when non association issues' do
    let(:reason) { 'prisoner_non_association' }

    it { expect(mail.html_part.body).to match(/is now restricted/) }
  end

  context 'when booked in error' do
    let(:reason) { 'booked_in_error' }

    it { expect(mail.html_part.body).to match(/booked in error/) }
  end
end
