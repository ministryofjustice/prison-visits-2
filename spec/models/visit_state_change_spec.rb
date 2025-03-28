require 'rails_helper'

RSpec.describe VisitStateChange, type: :model do
  it { should belong_to(:visit) }

  it { is_expected.to belong_to(:creator).optional }

  describe 'scopes' do
    let(:visit) { create(:visit) }

    let(:booked) {
      described_class.create(visit_state: 'booked', visit:)
    }

    let(:rejected) {
      described_class.create(visit_state: 'rejected', visit:)
    }

    let(:cancelled) {
      described_class.create(visit_state: 'cancelled', visit:)
    }

    let(:withdrawn) {
      described_class.create(visit_state: 'withdrawn', visit:)
    }

    it 'has a booked scope' do
      expect(described_class.booked).to contain_exactly(booked)
    end

    it 'has a rejected scope' do
      expect(described_class.rejected).to contain_exactly(rejected)
    end

    it 'has a cancelled scope' do
      expect(described_class.cancelled).to contain_exactly(cancelled)
    end

    it 'has a withdrawn scope' do
      expect(described_class.withdrawn).to contain_exactly(withdrawn)
    end
  end
end
