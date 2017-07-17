require 'rails_helper'

RSpec.describe PrisonerRestrictionList do
  let(:offender) do
    Nomis::Offender.new(id: 1, noms_id: 'prisoner_number')
  end

  subject { described_class.new(offender) }

  describe '#on_slot' do
    let(:slot_date) { Time.zone.today }
    let(:slot) do
      ConcreteSlot.new(slot_date.year, slot_date.month, slot_date.day, 14, 30, 15, 30)
    end

    let(:restriction_code) { Nomis::Restriction::CLOSED_CODE }
    let(:effective_date) { slot_date }
    let(:expiry_date) { effective_date + 1.week }
    let(:restriction) do
      Nomis::Restriction.new(
        type: { code: restriction_code },
        effective_date: effective_date,
        expiry_date: expiry_date
      )
    end

    before do
      mock_nomis_with(:fetch_offender_restrictions,
        Nomis::OffenderRestrictions.new(restrictions: [restriction]))
    end

    context 'when the restriction is effective' do
      let(:effective_date) { slot_date }

      context 'when is a closed restriction' do
        let(:restriction_code) { 'CLOSED' }

        it { expect(subject.on_slot(slot)).to eq(['closed']) }
      end

      context 'when is not a closed restriction' do
        let(:restriction_code) { 'BAN' }

        it { expect(subject.on_slot(slot)).to be_empty }
      end
    end

    context 'when the restriction has expired' do
      let(:effective_date) { slot_date - 2.weeks }
      let(:expiry_date) { slot_date - 1.week }

      it { expect(subject.on_slot(slot)).to be_empty }
    end
  end
end
