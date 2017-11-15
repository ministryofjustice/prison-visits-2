require 'rails_helper'

RSpec.describe VisitDecorator do
  let(:visit) { create(:visit) }
  let(:checker) { instance_double(StaffNomisChecker) }

  subject do
    described_class.decorate(visit, context: { staff_nomis_checker: checker })
  end

  describe '#prisoner_restrictions' do
    let(:restriction) { Nomis::Restriction.new }

    before do
      expect(checker).
        to receive(:prisoner_restrictions).and_return([restriction])
    end

    it { expect(subject.prisoner_restrictions).to all(be_decorated) }
  end

  describe '#slots'do
    it 'are decorated object' do
      expect(subject.slots).to all(be_decorated)
    end
  end

  describe '#nomis_offender_id' do
    context 'when the Nomis::Api is enabled' do
      let(:offender) { double(Nomis::Offender, id: 1234) }

      before do
        expect(checker).to receive(:offender).and_return(offender)
      end

      it 'returns the offender id' do
        expect(subject.nomis_offender_id).to eq(offender.id)
      end
    end

    context 'when the Nomis::Api is disabled' do
      before do
        switch_off_api
      end
      it 'does not call the API' do
        expect(checker).not_to receive(:offender)
        subject.nomis_offender_id
      end
    end
  end

  describe '#processed_at' do
    context 'when requested' do
      let(:visit) { create(:visit, :requested) }

      it 'returns the visit creation time' do
        expect(subject.processed_at).to eq(visit.created_at)
      end
    end

    context 'when not requested' do
      let!(:last_state_change) do
        VisitStateChange.create!(visit: visit,
                                 visit_state: 'cancelled',
                                 created_at: 1.day.from_now)
      end

      it 'returns the last visit state change creation time' do
        expect(subject.processed_at).to eq(last_state_change.reload.created_at)
      end
    end
  end

  describe '#bookable?' do
    context 'when there is a bookable slot' do
      before do
        expect(subject.slots.first).to receive(:bookable?).and_return(true)
      end

      context 'when the contact list is working' do
        before do
          expect(Nomis::Feature).
            to receive(:contact_list_enabled?).with(visit.prison_name).and_return(true)
          expect(checker).to receive(:contact_list_unknown?).and_return(false)
          allow(checker).to receive(:approved_contacts).and_return([])
        end

        context 'when there is an exact matched visitor is banned' do
          before do
            expect(subject.principal_visitor).to receive(:exact_match?).and_return(true)
            expect(subject.principal_visitor).to receive(:banned?).and_return(true)
          end

          it { expect(subject).not_to be_bookable }
        end

        context 'when there is an unbanned exact match' do
          before do
            expect(subject.principal_visitor).to receive(:exact_match?).and_return(true)
            expect(subject.principal_visitor).to receive(:banned?).and_return(false)
          end

          it { expect(subject).to be_bookable }
        end

        context 'when there is not an exact match' do
          before do
            expect(subject.principal_visitor).to receive(:exact_match?).and_return(false)
          end

          it { expect(subject).not_to be_bookable }
        end
      end

      context 'when the contact list is not working' do
        before do
          expect(Nomis::Feature).
            to receive(:contact_list_enabled?).with(visit.prison_name).and_return(true)
          expect(checker).to receive(:contact_list_unknown?).and_return(true)
        end

        it { expect(subject).not_to be_bookable }
      end
    end
  end
end
