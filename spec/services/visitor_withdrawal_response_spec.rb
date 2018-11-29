require 'rails_helper'

RSpec.describe VisitorWithdrawalResponse do
  subject(:instance) { described_class.new(visit: visit) }

  let(:visit) { create(:visit) }

  describe '#visitor_can_withdraw?' do
    subject(:visitor_can_withdraw?) { instance.visitor_can_withdraw? }

    context "when it can't be withdrawn" do
      let(:visit) { create(:withdrawn_visit) }

      it { is_expected.to eq(false) }
    end

    context 'when the visit is requested' do
      it { is_expected.to eq(true) }
    end
  end

  describe 'withdraw!' do
    it 'process the withdrawal and enqueues the email' do
      expect_any_instance_of(BookingResponder::VisitorWithdrawal).to receive(:process_request)

      instance.withdraw!
    end
  end
end
