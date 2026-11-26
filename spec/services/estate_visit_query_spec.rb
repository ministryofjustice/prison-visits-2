require 'rails_helper'

RSpec.describe EstateVisitQuery do
  subject(:instance) { described_class.new(estates) }

  let(:prison) { create(:prison) }
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
        prison:,
        slot_granted: slot1)
    end
    let!(:booked_visit2) do
      create(:booked_visit,
             prison:,
             slot_granted: slot2)
    end
    let!(:cancelled_visit) do
      create(:cancelled_visit,
             prison:,
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
      instance.processed(limit:, query: prisoner_number)
    end

    let(:limit) { 10 }
    let(:prisoner_number) { nil }

    context 'with visits in all possible states' do
      let!(:requested) do
        create(:visit, :requested, prison:)
      end
      let!(:withdrawn) do
        create(:withdrawn_visit, prison:)
      end
      let!(:booked) do
        create(:booked_visit, prison:)
      end
      let!(:rejected) do
        create(:rejected_visit, prison:)
      end
      let!(:nomis_cancelled) do
        create(:visit,
               :nomis_cancelled,
               prison:,
               updated_at: 1.day.ago)
      end
      let!(:pending_nomis_cancellation) do
        create(:visit, :pending_nomis_cancellation, prison:)
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
        let!(:old_booked) { create(:booked_visit, prison:, updated_at: 7.months.ago) }
        let(:prisoner_number) { old_booked.prisoner.number.downcase }

        it 'does not return visits in search results' do
          expect(instance.processed(limit:, query: prisoner_number)).to be_empty
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
      instance.requested(query:)
    end

    let!(:visit1) do
      create(:visit, :requested, prison:)
    end

    let!(:visit2) do
      create(:visit, :requested, prison:)
    end

    let!(:old_visit) do
      create(:visit, :requested, prison:, created_at: 7.months.ago, updated_at: 7.months.ago)
    end

    it_behaves_like 'finds all'
    it_behaves_like 'finds by prisoner number'
    it_behaves_like 'finds by human id'
    it_behaves_like "doesn't find old records"
  end

  describe '#cancelled' do
    subject do
      instance.cancelled(query:)
    end

    let!(:visit1) do
      create(:visit, :pending_nomis_cancellation, prison:)
    end
    let!(:visit2) do
      create(:visit, :pending_nomis_cancellation, prison:)
    end

    let!(:old_visit) do
      create(:visit, :pending_nomis_cancellation, prison:, created_at: 7.months.ago, updated_at: 7.months.ago)
    end

    it_behaves_like 'finds all'
    it_behaves_like 'finds by prisoner number'
    it_behaves_like 'finds by human id'
    it_behaves_like "doesn't find old records"
  end

  shared_examples 'scoped identifier searches' do |query_method, visit_trait|
    let!(:matching_visit) {
      create(:visit, visit_trait, prison:, created_at: 2.days.ago, updated_at: 1.day.ago)
    }
    let(:find_matches) {
      lambda { |query|
        if query_method == :processed
          instance.processed(limit: 10, query:)
        else
          instance.public_send(query_method, query:)
        end
      }
    }

    it 'normalises case and surrounding whitespace' do
      expect(find_matches.call("  #{matching_visit.prisoner.number.downcase}  "))
        .to eq([matching_visit])
    end

    it 'normalises reference case and surrounding whitespace' do
      expect(find_matches.call("  #{matching_visit.human_id.downcase}  "))
        .to eq([matching_visit])
    end

    it 'returns visits for separate prisoner records sharing a number' do
      other_prisoner = create(:prisoner, number: matching_visit.prisoner.number)
      another_visit = create(:visit, visit_trait, prison:, prisoner: other_prisoner)

      expect(find_matches.call(matching_visit.prisoner.number))
        .to contain_exactly(matching_visit, another_visit)
    end

    it 'does not duplicate a visit matching both identifiers' do
      matching_visit.update!(human_id: matching_visit.prisoner.number)

      expect(find_matches.call(matching_visit.human_id)).to eq([matching_visit])
    end

    it 'returns both visits when different identifiers match the same query' do
      another_visit = create(:visit, visit_trait, prison:, human_id: matching_visit.prisoner.number)

      expect(find_matches.call(matching_visit.prisoner.number))
        .to contain_exactly(matching_visit, another_visit)
    end

    it 'excludes other estates from both identifier branches' do
      create(:visit, visit_trait, prisoner: matching_visit.prisoner)
      create(:visit, visit_trait, human_id: matching_visit.prisoner.number)

      expect(find_matches.call(matching_visit.prisoner.number)).to eq([matching_visit])
    end

    it 'applies the six-month update cutoff to reference matches' do
      matching_visit.update_columns(updated_at: 7.months.ago)

      expect(find_matches.call(matching_visit.human_id)).to be_empty
    end

    it 'uses the update date rather than the creation date for search eligibility' do
      matching_visit.update_columns(created_at: 7.months.ago)

      expect(find_matches.call(matching_visit.human_id)).to eq([matching_visit])
    end

    it 'keeps the existing result ordering after merging identifier branches' do
      another_visit = create(:visit, visit_trait, prison:, human_id: matching_visit.prisoner.number)
      expected = query_method == :processed ? [another_visit, matching_visit] : [matching_visit, another_visit]

      expect(find_matches.call(matching_visit.prisoner.number)).to eq(expected)
    end

    it 'matches identifiers exactly rather than as patterns or SQL' do
      expect(find_matches.call('%')).to be_empty
      expect(find_matches.call("' OR 1=1 --")).to be_empty
    end

    it 'retains preloaded associations' do
      found_visit = find_matches.call(matching_visit.human_id).sole

      expect(found_visit.association(:prisoner)).to be_loaded
      expect(found_visit.association(:visitors)).to be_loaded
      expect(found_visit.association(:prison)).to be_loaded
    end
  end

  context 'when searching requested visits' do
    include_examples 'scoped identifier searches', :requested, :requested

    it 'keeps the prisoner number visible to generic query plans' do
      queries = []
      subscriber = ->(*arguments) { queries << arguments.last[:sql] }
      number = matching_visit.prisoner.number

      ActiveSupport::Notifications.subscribed(subscriber, 'sql.active_record') do
        find_matches.call(number)
      end

      search_sql = queries.find { |sql| sql.include?('UNION') }
      predicate = "\"prisoners\".\"number\" = #{Prisoner.connection.quote(number)}"

      expect(search_sql).to be_present
      expect(search_sql).to include(predicate)
    end

    it 'does not include processed reference matches' do
      matching_visit.update_columns(processing_state: 'booked')

      expect(find_matches.call(matching_visit.human_id)).to be_empty
    end
  end

  context 'when searching processed visits' do
    include_examples 'scoped identifier searches', :processed, :booked

    it 'applies the limit after merging identifier matches in update order' do
      another_visit = create(:visit, :booked, prison:, human_id: matching_visit.prisoner.number)

      expect(instance.processed(limit: 1, query: matching_visit.prisoner.number)).to eq([another_visit])
    end

    it 'does not include requested reference matches' do
      matching_visit.update_columns(processing_state: 'requested')

      expect(find_matches.call(matching_visit.human_id)).to be_empty
    end

    it 'excludes reference matches still pending NOMIS cancellation' do
      create(:cancellation, visit: matching_visit, nomis_cancelled: false)

      expect(find_matches.call(matching_visit.human_id)).to be_empty
    end
  end

  context 'when searching cancelled visits' do
    include_examples 'scoped identifier searches', :cancelled, :pending_nomis_cancellation

    it 'excludes reference matches whose NOMIS cancellation is confirmed' do
      matching_visit.cancellation.update!(nomis_cancelled: true)

      expect(find_matches.call(matching_visit.human_id)).to be_empty
    end
  end

  describe 'supporting indexes' do
    [
      [Prisoner, 'index_prisoners_on_number', ['number']],
      [Visit, 'index_visits_on_prisoner_id', ['prisoner_id']],
      [Visit, 'index_visits_for_requested_dashboard', %w[prison_id processing_state created_at]],
      [Visit, 'index_visits_on_prison_id_and_updated_at', %w[prison_id updated_at]]
    ].each do |model, index_name, columns|
      it "has the nonunique #{index_name} index" do
        index = model.connection.indexes(model.table_name).find { |definition| definition.name == index_name }

        expect(index).to have_attributes(columns:, unique: false, where: nil)
      end
    end
  end

  describe '#inbox_count' do
    subject(:inbox_count) { instance.inbox_count }

    context 'with visits in different estates' do
      before do
        create(:visit, :requested, prison:)
        create(:visit, :requested, prison:)
        create(:booked_visit, prison:)
        create(:rejected_visit, prison:)
        create(:visit,
               :nomis_cancelled,
               prison:,
               updated_at: 1.day.ago)
        create(:visit, :pending_nomis_cancellation, prison:)
      end

      it 'returns the count of the visits that are in the inbox' do
        expect(subject).to eq(3)
      end
    end
  end
end
