require 'rails_helper'

RSpec.describe EstateVisitQuery do
  subject(:instance) { described_class.new([estate]) }

  let(:prison) { FactoryGirl.create(:prison) }
  let(:estate) { prison.estate }

  describe '#visits_to_print_by_slot' do
    subject(:visits_to_print_by_slot) do
      instance.visits_to_print_by_slot(date)
    end

    let(:slot1) { ConcreteSlot.new(2016, 7, 19, 10, 30, 11, 30) }
    let(:slot2) { ConcreteSlot.new(2016, 7, 19, 14, 30, 15, 30) }
    let(:date) { slot1.to_date }
    let!(:booked_visit1) do
      FactoryGirl.create(
        :booked_visit,
        prison: prison,
        slot_granted: slot1)
    end
    let!(:booked_visit2) do
      FactoryGirl.create(:booked_visit,
        prison: prison,
        slot_granted: slot2)
    end
    let!(:cancelled_visit) do
      FactoryGirl.create(:cancelled_visit,
        prison: prison,
        slot_granted: slot1)
    end

    it 'returns the data grouped by state and slot' do
      is_expected.to eq('booked' => {
                          slot1 => [booked_visit1],
                          slot2 => [booked_visit2]
                        },
                        'cancelled' => { slot1 => [cancelled_visit] })
    end
  end

  describe '#processed' do
    subject(:processed) do
      instance.processed(limit: limit)
    end

    let(:limit) { 10 }

    context 'with visits in all possible states' do
      let!(:requested) do
        FactoryGirl.create(:visit, :requested, prison: prison)
      end
      let!(:withdrawn) do
        FactoryGirl.create(:withdrawn_visit, prison: prison)
      end
      let!(:booked) do
        FactoryGirl.create(:booked_visit, prison: prison)
      end
      let!(:rejected) do
        FactoryGirl.create(:rejected_visit, prison: prison)
      end
      let!(:nomis_cancelled) do
        FactoryGirl.create(:visit,
          :nomis_cancelled,
          prison: prison,
          updated_at: 1.day.ago)
      end
      let!(:pending_nomis_cancellation) do
        FactoryGirl.create(:visit, :pending_nomis_cancellation, prison: prison)
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
    end
  end

  describe '#inbox_count' do
    subject(:inbox_count) { instance.inbox_count }

    context 'with visits in different estates' do
      before do
        FactoryGirl.create(:visit, :requested, prison: prison)
        FactoryGirl.create(:visit, :requested, prison: prison)
        FactoryGirl.create(:booked_visit, prison: prison)
        FactoryGirl.create(:rejected_visit, prison: prison)
        FactoryGirl.create(:visit,
          :nomis_cancelled,
          prison: prison,
          updated_at: 1.day.ago)
        FactoryGirl.create(:visit, :pending_nomis_cancellation, prison: prison)
      end

      it 'returns the count of the visits that are in the inbox' do
        is_expected.to eq(3)
      end
    end
  end
end
