# -*- coding: utf-8 -*-
require 'rails_helper'
require 'mailers/shared_mailer_examples'

RSpec.describe VisitorMailer, '.rejected' do
  let(:visit) { create :visit }
  let(:reason) { 'slot_unavailable' }
  let(:booking_response) do
    BookingResponse.new(
      visit:     visit
    )
  end
  let(:mail) { described_class.rejected(booking_response.email_attrs, message_attributes) }
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

  context 'always' do
    it 'sends an email reporting the rejection' do
      expect(mail.subject).
        to match(/Your visit to #{visit.prison_name} is NOT booked/)
    end

    it 'uses the locale of the visit' do
      pending('Wait for Welsh translation')
      visit.update locale: 'cy'
      expect(mail.subject).
        to match(
          /nid oedd yn bosib trefnu eich ymweliad ar Dydd Llun 12 Hydref/)
    end

    it 'includes the visit id' do
      expect(mail.body.encoded).to match(visit.id)
    end

    context 'includes information about banned visitors' do
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
          first_name: 'John',
          last_name: 'Johnson',
          sort_index: 2
        )
      end

      it 'explains the error' do
        expect(body).to match(/banned from visiting the prison/)
      end

      it 'enumerates the banned visitors' do
        expect(body).to match(/Percy P and John J are banned from visiting the prison at the moment/)
      end
    end

    context 'includes information about not on list visitors' do
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
    let(:message) { FactoryGirl.build_stubbed(:message) }
    let(:message_attributes) { message.attributes.slice('body') }

    it 'displays the message' do
      expect(body).to match(message.body)
    end
  end

  context 'slot_unavailable' do
    let(:reason) { 'slot_unavailable' }

    include_examples 'template checks'
  end

  context 'no_allowance' do
    include_examples 'template checks'

    before do
      visit.rejection.reasons = ['no_allowance']
      visit.rejection.privileged_allowance_available  = true
      visit.rejection.allowance_will_renew            = true
      visit.rejection.allowance_renews_on             = Date.new(2015, 10, 1)
      visit.rejection.privileged_allowance_expires_on = Date.new(2015, 10, 2)
    end

    it 'explains the error' do
      expect(body).to match(/prisoner has used their allowance of visits for this month/)
    end

    it 'explains allowance renewal' do
      expect(body).to match(/you can only book a visit from Thursday 1 October onwards/)
    end
  end

  context 'prisoner_details_incorrect' do
    let(:reason) { 'prisoner_details_incorrect' }

    include_examples 'template checks'

    it 'explains the error' do
      expect(body).to match(/we can't find the prisoner from the information you've given/)
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
      expect(body).to match(/children under 18 can only visit prison with an adult and you've not listed any adults/)
    end
  end
end
