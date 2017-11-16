require "rails_helper"

RSpec.describe CancelNomisVisit do
  let(:visit)                      { create(:booked_visit, nomis_id: 1234) }
  let(:reasons)                    { [Cancellation::PRISONER_RELEASED] }
  let(:expected_cancellation_code) { described_class::ADMIN }

  subject { described_class.new(visit) }

  before do
    visit.prisoner.nomis_offender_id = '123456'
    visit.build_cancellation(reasons: reasons, nomis_cancelled: true)
  end

  describe '#execute' do
    context 'when successfully cancelling' do
      let(:params) do
        { comment: 'A cancellation message' }
      end

      let(:nomis_cancellation) do
        Nomis::Cancellation.new('message' => 'Visit cancelled')
      end

      let(:expected_params) {
        params.merge(
          cancellation_code: expected_cancellation_code
        )
      }

      before do
        expect(Nomis::Api.instance).
          to receive(:cancel_visit).
               with(
                 visit.prisoner.nomis_offender_id,
                 visit.nomis_id,
                 params: expected_params
               ).and_return(nomis_cancellation)
      end

      context 'with only one cancellation code' do
        it 'has cancelled the visit' do
          expect(subject.execute(params)).to be_success
        end
      end

      context 'with multiple cancellation code' do
        context 'with NO_VO & ADMIN' do
          let(:reasons)                    do
            [Cancellation::PRISONER_MOVED, Cancellation::PRISONER_VOS]
          end
          let(:expected_cancellation_code) { described_class::NO_VO }

          it 'prioritises NO_VO' do
            expect(subject.execute(params)).to be_success
          end
        end

        context 'with OFFCANC & ADMIN' do
          let(:reasons)                    do
            [Cancellation::PRISONER_MOVED, Cancellation::PRISONER_CANCELLED]
          end
          let(:expected_cancellation_code) { described_class::OFFCANC }

          it 'prioritises OFFCANC'do
            expect(subject.execute(params)).to be_success
          end
        end
      end
    end

    context 'when unsucessfully cancellation' do
      context 'with an unexpected error' do
        before do
          simulate_api_error_for :cancel_visit
        end

        it 'a nomis API error' do
          expect(subject.execute).to have_attributes(message: BookingResponse::NOMIS_API_ERROR)
        end
      end

      context 'with an expected error message' do
        let(:cancellation) do
          Nomis::Cancellation.new('error' => { 'message' => error_message })
        end

        before { mock_nomis_with :cancel_visit, cancellation }

        context 'when the visit is not found' do
          let(:error_message) { 'Visit not found' }

          it do
            expect(subject.execute).
              to have_attributes(message: BookingResponse::VISIT_NOT_FOUND)
          end
        end

        context 'when the visit has already been cancelled' do
          let(:error_message) { 'Visit already cancelled' }

          it do
            expect(subject.execute).
              to have_attributes(message: BookingResponse::VISIT_ALREADY_CANCELLED)
          end
        end

        context 'when the visit has already been completed' do
          let(:error_message) { 'Visit completed' }

          it do
            expect(subject.execute).
              to have_attributes(message: BookingResponse::VISIT_COMPLETED)
          end
        end

        context 'when the cancellation code is invalid' do
          let(:error_message) { 'Invalid or missing visit_id' }

          it do
            expect(subject.execute).
              to have_attributes(message: BookingResponse::INVALID_CANCELLATION_CODE)
          end
        end
      end
    end
  end
end
