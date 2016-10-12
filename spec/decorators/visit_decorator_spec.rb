require 'rails_helper'

RSpec.describe VisitDecorator do
  let(:visit) { create(:visit) }
  subject { described_class.decorate(visit) }

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
end
