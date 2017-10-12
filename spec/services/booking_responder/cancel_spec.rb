require 'rails_helper'

RSpec.shared_examples_for 'Non NOMIS API calls' do
  it 'does not cancel to NOMIS' do
    expect(cancellation_creator).not_to receive(:execute)
    subject.process_request
  end
end

RSpec.describe BookingResponder::Cancel do
  subject(:instance) { described_class.new(cancellation_response, options) }

  let(:cancellation_response) do
    CancellationResponse.new(visit, reasons: reasons)
  end
  let(:nomis_id)             { nil }
  let(:visit)                { create(:booked_visit, nomis_id: nomis_id) }
  let(:reasons)              { [Cancellation::BOOKED_IN_ERROR] }
  let(:user)                 { create(:user) }
  let(:cancellation_creator) { instance_double(CancelNomisVisit) }
  let(:booking_response)     { BookingResponse.successful  }
  let(:options)              { {} }

  before do
    allow(CancelNomisVisit).to receive(:new).and_return(cancellation_creator)
    expect(cancellation_response).to be_valid
  end

  it 'cancels the visit and marks it as manually cancelled ' do
    instance.process_request

    visit.reload
    expect(visit).to be_cancelled
    expect(visit.cancellation.reasons).to eq(reasons)
    expect(visit.cancellation.nomis_cancelled).to eq(true)
  end

  context 'with persist_to_nomis off' do
    let(:options) { { persist_to_nomis: false } }

    context 'with book to nomis enabled' do
      before do
        switch_on :nomis_staff_book_to_nomis_enabled
        switch_feature_flag_with :staff_prisons_with_book_to_nomis, [visit.prison_name]
      end

      include_examples 'Non NOMIS API calls'
    end
  end

  context 'with persist_to_nomis on' do
    let(:options) { { persist_to_nomis: true } }

    context 'with book to nomis enabled' do
      context 'when the visit has a nomis_id' do
        let(:nomis_id) { 654_651 }

        before do
          switch_on :nomis_staff_book_to_nomis_enabled
          switch_feature_flag_with :staff_prisons_with_book_to_nomis, [visit.prison_name]
        end

        it 'cancels to NOMIS' do
          expect(cancellation_creator).to receive(:execute).and_return(booking_response)
          subject.process_request
        end
      end

      context 'when the visit does not have a nomis_id' do
        include_examples 'Non NOMIS API calls'
      end
    end

    context 'without book to nomis enabled' do
      before do
        switch_feature_off_for(:book_to_nomis_enabled?, visit.prison_name)
      end

      it 'does not cancel to NOMIS' do
        expect(cancellation_creator).not_to receive(:execute)
        subject.process_request
      end
    end
  end
end
