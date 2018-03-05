require 'rails_helper'

RSpec.describe CreateNomisVisit do
  let(:prisoner) { FactoryBot.build_stubbed(:prisoner, nomis_offender_id: 12_345) }
  let(:lead_visitor) { FactoryBot.build_stubbed(:visitor, nomis_id: 1234, sort_index: 0) }
  let(:additional_visitor) { FactoryBot.build_stubbed(:visitor, nomis_id: 2345, sort_index: 1) }
  let(:banned_visitor) { FactoryBot.build_stubbed(:visitor, nomis_id: 2345, banned: true, sort_index: 2) }

  let(:visit) do
    FactoryBot.build_stubbed(:booked_visit,
      prisoner: prisoner,
      visitors: [lead_visitor, additional_visitor, banned_visitor])
  end

  let(:booking) { Nomis::Booking.new(visit_id: 99_999) }

  subject { described_class.new(visit) }

  before do
    allow(Nomis::Api.instance).to receive(:book_visit).and_return(booking)
  end

  describe '#execute' do
    let(:booking_response) { subject.execute }

    describe 'api call to Nomis' do
      it 'with the correct parameters' do
        expect(Nomis::Api.instance).
          to receive(:book_visit).
          with(offender_id: prisoner.nomis_offender_id,
               params: {
                 lead_contact: lead_visitor.nomis_id,
                 other_contacts: [additional_visitor.nomis_id],
                 slot: visit.slot_granted.to_s,
                 override_restrictions: false,
                 client_unique_ref: visit.id
               }).and_return(Nomis::Booking.new)

        subject.execute
      end
    end

    describe 'successful booking' do
      let(:booking) { Nomis::Booking.new(visit_id: 99_999) }

      it { expect(subject.execute).to be_success }
    end

    describe 'validation errors' do
      let(:error_message) { 'overlapping visit' }
      let(:booking) { Nomis::Booking.new(error_message: error_message) }

      it { expect(subject.execute).not_to be_success }
      it { expect(subject.execute).to have_attributes(message: BookingResponse::NOMIS_VALIDATION_ERROR) }
    end

    describe 'api errors' do
      before do
        allow(Nomis::Api.instance).
          to receive(:book_visit).and_raise(Nomis::APIError, 'timeout')
      end

      it { expect(subject.execute).not_to be_success }
      it { expect(subject.execute).to have_attributes(message: BookingResponse::NOMIS_API_ERROR) }
    end

    describe 'duplicate post' do
      let(:error_message) { 'Duplicate post' }
      let(:booking) { Nomis::Booking.new(error_messages: [error_message]) }

      it { expect(subject.execute).not_to be_success }
      it { expect(subject.execute).to have_attributes(message: BookingResponse::ALREADY_BOOKED_IN_NOMIS_ERROR) }
    end
  end

  describe '#nomis_visit_id' do
    let(:nomis_visit_id) { 99_999 }
    let(:booking) { Nomis::Booking.new(visit_id: nomis_visit_id) }

    before do
      subject.execute
    end

    it { expect(subject.nomis_visit_id).to eq(nomis_visit_id) }
  end
end
