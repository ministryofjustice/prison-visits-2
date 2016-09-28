require "rails_helper"

RSpec.describe BookingResponder::Reject do
  include_context 'booking request processor setup'

  it 'process the visit' do
    expect {
      subject.process_request
    }.to change {
      visit.processing_state
    }.from('requested').to('rejected').and change {
      visit.reload.rejection&.reason
    }.from(nil).to('visitor_not_on_list')
  end

  context 'without allowance' do
    before do
      params.merge!(
        selection:            Rejection::NO_ALLOWANCE,
        unlisted_visitor_ids: [],
        banned_visitor_ids:   []
      )
    end

    it 'has set the rejection reason to no allowance' do
      subject.process_request
      expect(visit.reload.rejection_reason).to eq(Rejection::NO_ALLOWANCE)
      expect(visit.reload.allowance_renews_on).to be nil
    end

    context 'when allowance with renew' do
      let(:allowance_date) { Time.zone.today + 7 }

      before do
        booking_response.allowance_will_renew = true
        booking_response.allowance_renews_on  = allowance_date
      end

      it 'sets the allowance renewal date' do
        subject.process_request
        expect(visit.reload.allowance_renews_on).to eq(allowance_date)
      end
    end

    context 'when privileged allowance will renew' do
      let(:privileded_allowance_date) { Time.zone.today + 8 }

      before do
        booking_response.privileged_allowance_available = true
        booking_response.privileged_allowance_expires_on  = privileded_allowance_date
      end

      it 'sets the priviledge allowance renewal date' do
        subject.process_request
        expect(visit.reload.privileged_allowance_expires_on).to eq(privileded_allowance_date)
      end
    end
  end
end
