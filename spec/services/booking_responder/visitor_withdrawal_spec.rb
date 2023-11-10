require 'rails_helper'

RSpec.describe BookingResponder::VisitorWithdrawal do
  subject(:instance) { described_class.new(visitor_withdrawal_response) }

  let(:visitor_withdrawal_response) do
    VisitorWithdrawalResponse.new(visit:)
  end
  let(:visit) { FactoryBot.create(:visit) }

  it 'withdraws the visit' do
    instance.process_request

    visit.reload
    expect(visit).to be_withdrawn
  end
end
