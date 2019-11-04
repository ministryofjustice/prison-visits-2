require 'rails_helper'

RSpec.describe EstateVisitQuery do
  subject(:instance) { described_class.new(estates) }

  let(:prison) { create(:prison_with_slots) }
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
      create(
        :booked_visit,
        prison: prison,
        slot_granted: slot1)
    end
    let!(:booked_visit2) do
      create(:booked_visit,
             prison: prison,
             slot_granted: slot2)
    end
    let!(:cancelled_visit) do
      create(:cancelled_visit,
             prison: prison,
             slot_granted: slot1)
    end
    let!(:other_prison_visit) do
      create(
        :booked_visit,
        slot_granted: slot1)
    end

    it 'returns the data grouped by prison, status and slot' do
      expect(subject).to eq(
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
        create(:visit, :requested, prison: prison)
      end
      let!(:withdrawn) do
        create(:withdrawn_visit, prison: prison)
      end
      let!(:booked) do
        create(:booked_visit, prison: prison)
      end
      let!(:rejected) do
        create(:rejected_visit, prison: prison)
      end
      let!(:nomis_cancelled) do
        create(:visit,
               :nomis_cancelled,
               prison: prison,
               updated_at: 1.day.ago)
      end
      let!(:pending_nomis_cancellation) do
        create(:visit, :pending_nomis_cancellation, prison: prison)
      end

      it 'excludes visits pending nomis cancellation and requested visits' do
        expect(subject).to eq([rejected, booked, withdrawn, nomis_cancelled])
      end

      context 'when limiting the results' do
        let(:limit) { 2 }

        it 'returns the maximum number of records' do
          expect(processed.size).to eq(limit)
        end
      end

      context 'when providing a prisoner number' do
        let(:prisoner_number) { booked.prisoner.number.downcase }

        it 'returns processed visits matching the prisoner number' do
          expect(subject).to eq([booked])
        end
      end

      context 'when visits have not been updated within six months' do
        let!(:old_booked) { create(:booked_visit, prison: prison, updated_at: 7.months.ago) }
        let(:prisoner_number) { old_booked.prisoner.number.downcase }

        it 'does not return visits in search results' do
          expect(instance.processed(limit: limit, query: prisoner_number)).to be_empty
        end
      end
    end
  end

  shared_examples_for 'finds all' do
    context 'with no query' do
      let(:query) { nil }

      it 'returns all requested ordered' do
        expect(subject).to eq([old_visit, visit1, visit2])
      end
    end
  end

  shared_examples_for 'finds by prisoner number' do
    context 'with prisoner number query' do
      let(:query) { visit1.prisoner.number }

      it 'returns only those matching prisoner number' do
        expect(subject).to eq([visit1])
      end
    end
  end

  shared_examples_for "doesn't find old records" do
    context 'with prisoner number query from an old visit' do
      let(:query) { old_visit.prisoner.number }

      it 'returns only those matching prisoner number' do
        expect(subject).to be_empty
      end
    end
  end

  shared_examples_for 'finds by human id' do
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
      create(:visit, :requested, prison: prison)
    end

    let!(:visit2) do
      create(:visit, :requested, prison: prison)
    end

    let!(:old_visit) do
      create(:visit, :requested, prison: prison, created_at: 7.months.ago, updated_at: 7.months.ago)
    end

    it_behaves_like 'finds all'
    it_behaves_like 'finds by prisoner number'
    it_behaves_like 'finds by human id'
    it_behaves_like "doesn't find old records"
  end

  describe '#cancelled' do
    subject do
      instance.cancelled(query: query)
    end

    let!(:visit1) do
      create(:visit, :pending_nomis_cancellation, prison: prison)
    end
    let!(:visit2) do
      create(:visit, :pending_nomis_cancellation, prison: prison)
    end

    let!(:old_visit) do
      create(:visit, :pending_nomis_cancellation, prison: prison, created_at: 7.months.ago, updated_at: 7.months.ago)
    end

    it_behaves_like 'finds all'
    it_behaves_like 'finds by prisoner number'
    it_behaves_like 'finds by human id'
    it_behaves_like "doesn't find old records"
  end

  describe '#inbox_count' do
    subject(:inbox_count) { instance.inbox_count }

    context 'with visits in different estates' do
      before do
        create(:visit, :requested, prison: prison)
        create(:visit, :requested, prison: prison)
        create(:booked_visit, prison: prison)
        create(:rejected_visit, prison: prison)
        create(:visit,
               :nomis_cancelled,
               prison: prison,
               updated_at: 1.day.ago)
        create(:visit, :pending_nomis_cancellation, prison: prison)
      end

      it 'returns the count of the visits that are in the inbox' do
        expect(subject).to eq(3)
      end
    end
  end
end
