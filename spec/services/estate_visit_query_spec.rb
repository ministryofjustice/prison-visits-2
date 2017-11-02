require 'rails_helper'

RSpec.describe EstateVisitQuery do
  subject(:instance) { described_class.new(estates) }

  let(:prison) { FactoryBot.create(:prison) }
  let(:estates) { [prison.estate] }

  describe '#visits_to_print_by_slot' do
    subject(:visits_to_print_by_slot) do
      instance.visits_to_print_by_slot(date)
    end

    let(:other_prison) { other_prison_visit.prison }
    let(:estates) { [prison.estate, other_prison.estate] }

    let(:slot1) { ConcreteSlot.new(2016, 7, 19, 10, 30, 11, 30) }
    let(:slot2) { ConcreteSlot.new(2016, 7, 19, 14, 30, 15, 30) }
    let(:date) { slot1.to_date }
    let!(:booked_visit1) do
      FactoryBot.create(
        :booked_visit,
        prison: prison,
        slot_granted: slot1)
    end
    let!(:booked_visit2) do
      FactoryBot.create(:booked_visit,
        prison: prison,
        slot_granted: slot2)
    end
    let!(:cancelled_visit) do
      FactoryBot.create(:cancelled_visit,
        prison: prison,
        slot_granted: slot1)
    end
    let!(:other_prison_visit) do
      FactoryBot.create(
        :booked_visit,
        slot_granted: slot1)
    end

    it 'returns the data grouped by prison, status and slot' do
      is_expected.to eq(
        prison.name => {
          'booked' => {
            slot1 => [booked_visit1],
            slot2 => [booked_visit2]
          },
          'cancelled' => { slot1 => [cancelled_visit] }
        },
        other_prison.name => {
          'booked' => {
            slot1 => [other_prison_visit]
          }
        })
    end
  end

  describe '#processed' do
    subject(:processed) do
      instance.processed(limit: limit, query: prisoner_number)
    end

    let(:limit) { 10 }
    let(:prisoner_number) { nil }

    context 'with visits in all possible states' do
      let!(:requested) do
        FactoryBot.create(:visit, :requested, prison: prison)
      end
      let!(:withdrawn) do
        FactoryBot.create(:withdrawn_visit, prison: prison)
      end
      let!(:booked) do
        FactoryBot.create(:booked_visit, prison: prison)
      end
      let!(:rejected) do
        FactoryBot.create(:rejected_visit, prison: prison)
      end
      let!(:nomis_cancelled) do
        FactoryBot.create(:visit,
          :nomis_cancelled,
          prison: prison,
          updated_at: 1.day.ago)
      end
      let!(:pending_nomis_cancellation) do
        FactoryBot.create(:visit, :pending_nomis_cancellation, prison: prison)
      end

      it 'excludes visits pending nomis cancellation and requested visits' do
        is_expected.to eq([rejected, booked, withdrawn, nomis_cancelled])
      end

      context 'limiting the results' do
        let(:limit) { 2 }

        it 'returns the maximum number of records' do
          expect(processed.size).to eq(limit)
        end
      end

      context 'providing a prisoner number' do
        let(:prisoner_number) { booked.prisoner.number.downcase + ' ' }

        it 'returns processed visits matching the prisoner number' do
          is_expected.to eq([booked])
        end
      end
    end
  end

  shared_examples_for :finds_all do
    context 'with no query' do
      let(:query) { nil }

      it 'returns all requested' do
        expect(subject).to eq([visit1, visit2])
      end
    end
  end

  shared_examples_for :finds_by_prisoner_number do
    context 'with prisoner number query' do
      let(:query) { visit1.prisoner.number }

      it 'returns only those matching prisoner number' do
        expect(subject).to eq([visit1])
      end
    end
  end

  shared_examples_for :finds_by_human_id do
    context 'with human ID query' do
      let(:query) { visit2.human_id }

      it 'returns only those matching human ID' do
        expect(subject).to eq([visit2])
      end
    end
  end

  describe '#requested' do
    subject do
      instance.requested(query: query)
    end

    let!(:visit1) do
      FactoryBot.create(:visit, :requested, prison: prison)
    end
    let!(:visit2) do
      FactoryBot.create(:visit, :requested, prison: prison)
    end

    it_behaves_like :finds_all
    it_behaves_like :finds_by_prisoner_number
    it_behaves_like :finds_by_human_id
  end

  describe '#cancelled' do
    subject do
      instance.cancelled(query: query)
    end

    let!(:visit1) do
      FactoryBot.create(:visit, :pending_nomis_cancellation, prison: prison)
    end
    let!(:visit2) do
      FactoryBot.create(:visit, :pending_nomis_cancellation, prison: prison)
    end

    it_behaves_like :finds_all
    it_behaves_like :finds_by_prisoner_number
    it_behaves_like :finds_by_human_id
  end

  describe '#inbox_count' do
    subject(:inbox_count) { instance.inbox_count }

    context 'with visits in different estates' do
      before do
        FactoryBot.create(:visit, :requested, prison: prison)
        FactoryBot.create(:visit, :requested, prison: prison)
        FactoryBot.create(:booked_visit, prison: prison)
        FactoryBot.create(:rejected_visit, prison: prison)
        FactoryBot.create(:visit,
          :nomis_cancelled,
          prison: prison,
          updated_at: 1.day.ago)
        FactoryBot.create(:visit, :pending_nomis_cancellation, prison: prison)
      end

      it 'returns the count of the visits that are in the inbox' do
        is_expected.to eq(3)
      end
    end
  end
end
