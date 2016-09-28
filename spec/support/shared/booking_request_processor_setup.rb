RSpec.shared_context 'booking request processor setup' do
  let(:user)              { create(:user) }
  let(:visit)             { create :visit_with_three_slots }
  let!(:visitor) { create(:visitor, visit: visit) }
  let(:unlisted_visitors) do
    create_list(:visitor, 2, visit: visit)
  end
  let(:banned_visitors)   do
    create_list(:visitor, 2, visit: visit)
  end
  let(:booking_response) { BookingResponse.new(params) }
  let(:params) do
    {
      user:                 user,
      visit:                visit,
      selection:            BookingResponse::SLOTS.sample,
      unlisted_visitor_ids: unlisted_visitors.map(&:id),
      banned_visitor_ids:   banned_visitors.map(&:id),
      message_body:         'a message from the team'
    }
  end

  subject { described_class.new(booking_response) }
end
