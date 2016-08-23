require 'rails_helper'
require 'mailers/shared_mailer_examples'

RSpec.describe VisitorMailer, '.rejected' do
  let(:rejection) { create(:rejection, reason: reason) }
  let(:reason) { 'slot_unavailable' }
  let(:mail) { described_class.rejected(rejection.visit) }
  let(:body) { mail.html_part.body }

  around do |example|
    travel_to Date.new(2015, 10, 1) do
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

    it 'uses the locale of the visit' do
      rejection.visit.update locale: 'cy'
      expect(mail.subject).
        to match(
          /nid oedd yn bosib trefnu eich ymweliad ar Dydd Llun 12 Hydref/)
    end

    it 'includes the visit id' do
      expect(mail.body.encoded).to match(rejection.visit_id)
    end

    context 'includes information about banned visitors' do
      before do
        rejection.visit.visitors << build(
          :visitor,
          banned: true,
          first_name: 'Percy',
          last_name: 'Perkins',
          sort_index: 1
        )
        rejection.visit.visitors << build(
          :visitor,
          banned: true,
          first_name: 'John',
          last_name: 'Johnson',
          sort_index: 2
        )
      end

      it 'explains the error' do
        expect(body).to match(/banned from visiting the prison/)
      end

      it 'enumerates the banned visitors' do
        expect(body).to match(/Percy P and John J should have received a letter/)
      end
    end

    context 'includes information about not on list visitors' do
      before do
        rejection.visit.visitors << build(
          :visitor,
          not_on_list: true,
          first_name: 'Percy',
          last_name: 'Perkins',
          sort_index: 1
        )
        rejection.visit.visitors << build(
          :visitor,
          not_on_list: true,
          first_name: 'John',
          last_name: 'Johnson',
          sort_index: 2
        )
      end

      it 'explains the error' do
        expect(body).to match(/ask them to update their contact list/)
      end

      it 'enumerates the banned visitors' do
        expect(body).to match(/details for Percy P and John J don’t match our/)
      end
    end
  end

  context 'with a rejection staff message' do
    let(:message) { FactoryGirl.build_stubbed(:message) }

    before do
      expect(rejection.visit).
        to receive(:rejection_message).and_return(message)
    end

    it 'displays the message' do
      expect(body).to match(message.body)
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
      expect(body).to match(/the prisoner has moved prisons/)
    end
  end

  context 'prisoner_released' do
    let(:reason) { 'prisoner_released' }

    include_examples 'template checks'

    it 'explains the error' do
      expect(body).to match(/the prisoner has been released/)
    end
  end

  context 'prisoner_non_association' do
    let(:reason) { 'prisoner_non_association' }

    include_examples 'template checks'

    it 'explains the error' do
      expect(body).to match(/the prisoner has a restriction/)
    end
  end

  context 'child_protection_issues' do
    let(:reason) { 'child_protection_issues' }

    include_examples 'template checks'

    it 'explains the error' do
      expect(body).to match(/the prisoner has a restriction/)
    end
  end

  context 'no_adult' do
    let(:reason) { 'no_adult' }

    include_examples 'template checks'

    it 'explains the error' do
      expect(body).to match(/at least one adult/)
    end
  end
end
