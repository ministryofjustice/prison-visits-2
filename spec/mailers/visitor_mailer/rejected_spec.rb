require 'rails_helper'
require 'mailers/shared_mailer_examples'

RSpec.describe VisitorMailer, '.rejected' do
  let(:rejection) { create(:rejection, reason: reason) }
  let(:reason) { 'slot_unavailable' }
  let(:mail) { described_class.rejected(rejection.visit) }
  let(:body) { mail.html_part.body }

  around do |example|
    Timecop.travel(Date.new(2015, 10, 1)) do
      example.call
    end
  end

  before do
    ActionMailer::Base.deliveries.clear
  end

  context 'always' do
    it 'sends an email reporting the rejection' do
      expect(mail.subject).
        to match(/your visit for Monday 12 October could not be booked/)
    end
  end

  context 'slot_unavailable' do
    let(:reason) { 'slot_unavailable' }

    include_examples 'template checks'
  end

  context 'no_allowance' do
    let(:rejection) {
      create(
        :rejection,
        reason: 'no_allowance',
        allowance_renews_on: Date.new(2015, 10, 1),
        privileged_allowance_expires_on: Date.new(2015, 10, 2)
      )
    }

    include_examples 'template checks'

    it 'explains the error' do
      expect(body).to match(/has not got any visiting allowance left/)
    end

    it 'explains privileged allowance expiry' do
      expect(body).to match(/valid until Friday 2 October/)
    end

    it 'explains allowance renewal' do
      expect(body).to match(/renewed on Thursday 1 October/)
    end
  end

  context 'prisoner_details_incorrect' do
    let(:reason) { 'prisoner_details_incorrect' }

    include_examples 'template checks'

    it 'explains the error' do
      expect(body).to match(/haven’t given correct information for the prisoner/)
    end
  end

  context 'prisoner_moved' do
    let(:reason) { 'prisoner_moved' }

    include_examples 'template checks'

    it 'explains the error' do
      expect(body).to match(/the prisoner you want to visit has moved prison/)
    end
  end

  context 'visitor_banned' do
    let(:reason) { 'visitor_banned' }

    include_examples 'template checks'

    it 'explains the error' do
      expect(body).to match(/banned from visiting the prison/)
    end
  end

  context 'visitor_not_on_list' do
    let(:reason) { 'visitor_not_on_list' }

    include_examples 'template checks'

    it 'explains the error' do
      expect(body).to match(/ask them to update their contact list/)
    end
  end
end
