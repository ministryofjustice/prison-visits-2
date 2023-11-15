require 'rails_helper'

RSpec.describe VisitStateChange, type: :model do
  it { should belong_to(:visit) }

  it { is_expected.to belong_to(:creator).optional }

  describe 'scopes' do
    let(:visit) { create(:visit) }

    let(:booked) {
      described_class.create(visit_state: 'booked', visit: visit)
    }

    let(:rejected) {
      described_class.create(visit_state: 'rejected', visit: visit)
    }

    let(:cancelled) {
      described_class.create(visit_state: 'cancelled', visit: visit)
    }

    let(:withdrawn) {
      described_class.create(visit_state: 'withdrawn', visit: visit)
    }

    it 'has a booked scope' do
      expect(described_class.booked).to match_array([booked])
    end

    it 'has a rejected scope' do
      expect(described_class.rejected).to match_array([rejected])
    end

    it 'has a cancelled scope' do
      expect(described_class.cancelled).to match_array([cancelled])
    end

    it 'has a withdrawn scope' do
      expect(described_class.withdrawn).to match_array([withdrawn])
    end
  end
end
