require 'rails_helper'

RSpec.describe VisitTimeline do
  let(:instance) { described_class.new(visit) }
  let(:visit) { create(:visit) }

  describe '#events' do
    subject(:events) { instance.events }

    describe 'for a requested visit' do
      it 'has only one requested event' do
        event = events.first
        expect(event.state).to eq('requested')
        expect(event.created_at).to eq(visit.created_at)
        expect(event.last).to eq(true)
        expect(event.user_name).to eq(visit.principal_visitor.full_name)
      end
    end

    describe 'for a staff cancelled visit' do
      let(:user) { FactoryBot.create(:user) }

      before do
        visit.accept
        VisitStateChange.last.update!(creator: user)

        CancellationResponse.new(
          visit, { reasons: [Cancellation::BOOKED_IN_ERROR] },
        ).tap(&:cancel!)

        VisitStateChange
          .find_by!(visit_state: 'cancelled')
          .update!(created_at: 1.minute.from_now)
        visit.reload
      end

      it 'has 3 events' do
        requested, booked, cancelled = events
        expect(requested.state).to eq('requested')
        expect(requested.last).to eq(false)

        expect(booked.state).to eq('booked')
        expect(booked.user_name).to eq(user.email)
        expect(booked.last).to eq(false)

        expect(cancelled.state).to eq('cancelled')
        expect(cancelled.last).to eq(true)
        expect(cancelled.user_name).to be_nil
      end
    end

    describe 'for a withdrawn visit' do
      before do
        visit.withdraw
        VisitStateChange.last.update!(creator: visit.principal_visitor)
        visit.reload
      end

      it 'records the user name from the visitor for the withdraw event' do
        _, withdrawn = events
        expect(withdrawn.user_name).to eq(visit.principal_visitor.full_name)
      end
    end
  end
end
