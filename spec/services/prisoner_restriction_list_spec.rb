require 'rails_helper'

RSpec.describe PrisonerRestrictionList do
  let(:prisoner) do
    Nomis::Prisoner.new(id: 1, noms_id: 'prisoner_number')
  end

  subject { described_class.new(prisoner) }

  context 'with #unknown_result?' do
    context "when it's a null prisoner" do
      let(:prisoner) { Nomis::NullPrisoner.new }

      it { is_expected.to be_unknown_result }
    end

    context "when the api returns an error" do
      before do
        simulate_api_error_for(:fetch_prisoner_restrictions)
      end

      it { is_expected.to be_unknown_result }
    end

    context "when the api returns no error" do
      let(:prisoner_restrictions) { Nomis::PrisonerRestrictions.new }

      before do
        mock_nomis_with(:fetch_prisoner_restrictions, prisoner_restrictions)
      end

      it { is_expected.not_to be_unknown_result }
    end
  end

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
        type: { 'code' => restriction_code },
        effective_date: effective_date,
        expiry_date: expiry_date
      )
    end

    before do
      mock_nomis_with(:fetch_prisoner_restrictions,
        Nomis::PrisonerRestrictions.new(restrictions: [restriction]))
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

  describe '#active' do
    before do
      mock_nomis_with(:fetch_prisoner_restrictions,
        Nomis::PrisonerRestrictions.new(restrictions: [restriction]))
    end

    let(:restriction) do
      Nomis::Restriction.new(
        effective_date: effective_date,
        expiry_date: expiry_date
      )
    end

    context 'with the restriction in the past' do
      let(:effective_date) { 3.days.ago.to_date }
      let(:expiry_date) { 1.day.ago.to_date }

      it { expect(subject.active).to be_empty }
    end

    context 'with the restriction not in the past' do
      let(:effective_date) { 3.days.ago.to_date }
      let(:expiry_date) { 3.days.from_now.to_date }

      it { expect(subject.active).to eq([restriction]) }
    end
  end
end
