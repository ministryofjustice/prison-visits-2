require 'rails_helper'

RSpec.describe VisitDecorator do
  let(:visit) { create(:visit) }
  subject(:instance) { described_class.decorate(visit) }

  describe '#prisoner_details_incorrect' do
    context 'when a user overrides the NOMIS validation' do
      before do
        visit.build_rejection(reasons: reasons)
      end

      context 'details are overriden as incorrect' do
        let(:reasons) { [Rejection::PRISONER_DETAILS_INCORRECT] }
        it {  expect(subject.prisoner_details_incorrect).to be true }
      end

      context 'fallback to validate against NOMIS' do
        let(:reasons)       { [] }
        let(:nomis_chekcer) { double(StaffNomisChecker) }

        it 'queries nomis API' do
          expect(StaffNomisChecker).to receive(:new).and_return(nomis_chekcer)
          expect(nomis_chekcer).to receive(:prisoner_existance_status)
          subject.prisoner_details_incorrect
        end
      end
    end
  end

  describe '#slots'do
    it 'are decorated object' do
      subject.slots.each do |slot|
        expect(slot).to be_decorated
      end
    end
  end

  describe '#processed_at' do
    subject(:processed_at) { instance.processed_at }

    context 'when requested' do
      let(:visit) { create(:visit, :requested) }

      it 'returns the visit creation time' do
        expect(processed_at).to eq(visit.created_at)
      end
    end

    context 'when not requested' do
      let!(:last_state_change) do
        VisitStateChange.create!(visit: visit,
                                 visit_state: 'cancelled',
                                 created_at: 1.day.from_now)
      end

      it 'returns the last visit state change creation time' do
        expect(processed_at).to eq(last_state_change.reload.created_at)
      end
    end
  end
end
