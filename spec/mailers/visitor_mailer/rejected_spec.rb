require 'rails_helper'
require 'mailers/shared_mailer_examples'

RSpec.describe VisitorMailer, '.rejected' do
  let(:visit) { create :visit }
  let(:reason) { 'slot_unavailable' }
  let(:staff_response) do
    StaffResponse.new(
      visit:     visit
    )
  end
  let(:mail) { described_class.rejected(staff_response.email_attrs, message_attributes) }
  let(:body) { mail.html_part.body }
  let(:message_attributes) { nil }

  around do |example|
    travel_to Date.new(2015, 10, 1) do
      example.call
    end
  end

  before do
    visit.rejection_attributes = { reasons: [reason] }
    ActionMailer::Base.deliveries.clear
  end

  context 'when always' do
    it 'sends an email reporting the rejection' do
      expect(mail.subject)
        .to match(/Your visit to #{visit.prison_name} is NOT booked/)
    end

    it 'uses the locale of the visit' do
      visit.update! locale: 'cy'
      expect(mail.subject)
        .to match(
          /NID yw eich ymweliad â Charchar #{visit.prison_name} wedi cael ei drefnu/)
    end

    it 'includes the visit human_id' do
      expect(mail.body.encoded).to match(visit.human_id)
    end

    context 'when it includes information about banned visitors' do
      before do
        visit.visitors << build(
          :visitor,
          banned: true,
          first_name: 'Percy',
          last_name: 'Perkins',
          sort_index: 1
        )
        visit.visitors << build(
          :visitor,
          banned: true,
          banned_until: 6.months.from_now.to_date,
          first_name: 'John',
          last_name: 'Johnson',
          sort_index: 2
        )
      end

      it 'explains the error' do
        expect(body).to match(/banned from visiting the prison/)
      end

      it 'enumerates the banned visitors' do
        expect(body).to match(/Percy P is banned from visiting the prison at the moment/)
        expect(body).to match(%r{John J is banned from visiting the prison until 01/04/2016})
      end
    end

    context 'when it includes information about not on list visitors' do
      before do
        visit.visitors << build(
          :visitor,
          not_on_list: true,
          first_name: 'Percy',
          last_name: 'Perkins',
          sort_index: 1
        )
        visit.visitors << build(
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
        expect(body).to match(/details for Percy P and John J don't match our/)
      end
    end
  end

  context 'with a rejection staff message' do
    let(:message) { FactoryBot.build_stubbed(:message) }
    let(:message_attributes) { message.attributes.slice('body') }

    it 'displays the message' do
      expect(body).to match(message.body)
    end
  end

  context 'when slot_unavailable' do
    let(:reason) { 'slot_unavailable' }

    include_examples 'template checks'
  end

  context 'with no_allowance' do
    before do
      visit.rejection.reasons = ['no_allowance']
      visit.rejection.allowance_renews_on = Date.new(2015, 10, 1)
    end

    include_examples 'template checks'

    it 'explains the error' do
      expect(body).to match(/prisoner has used their allowance of visits for this month/)
    end

    it 'explains allowance renewal' do
      expect(body).to match(/you can only book a visit from Thursday 1 October onwards/)
    end
  end

  context 'when prisoner_details_incorrect' do
    let(:reason) { 'prisoner_details_incorrect' }

    include_examples 'template checks'

    it 'explains the error' do
      expect(body).to match(/we can't find the prisoner from the information you've given/)
    end
  end

  context 'when prisoner_moved' do
    let(:reason) { 'prisoner_moved' }

    include_examples 'template checks'

    it 'explains the error' do
      expect(body).to match(/the prisoner has moved prisons/)
    end
  end

  context 'when prisoner_released' do
    let(:reason) { 'prisoner_released' }

    include_examples 'template checks'

    it 'explains the error' do
      expect(body).to match(/the prisoner has been released/)
    end
  end

  context 'when prisoner_non_association' do
    let(:reason) { 'prisoner_non_association' }

    include_examples 'template checks'

    it 'explains the error' do
      expect(body).to match(/the prisoner has a restriction/)
    end
  end

  context 'when child_protection_issues' do
    let(:reason) { 'child_protection_issues' }

    include_examples 'template checks'

    it 'explains the error' do
      expect(body).to match(/the prisoner has a restriction/)
    end
  end

  context 'when no_adult' do
    let(:reason) { 'no_adult' }

    include_examples 'template checks'

    it 'explains the error' do
      expect(body).to match(/children under 18 can only visit prison with an adult and you've not listed any adults/)
    end
  end

  # TODO: Remove once Medway is on Prison Finder
  context 'when the prison is Medway Secure Training Centre' do
    let(:medway) { create(:estate, name: 'Medway Secure Training Centre') }
    let(:medway_prison) { create(:prison, estate: medway) }
    let(:visit) { create(:visit, prison: medway_prison) }

    include_examples 'when the prison is not on prison finder'
  end
end
