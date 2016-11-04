require "rails_helper"

RSpec.describe BookingResponder::Accept do
  include_context 'booking response setup'

  let!(:unlisted_visitors) do
    create_list(:visitor, 2, visit: visit)
  end

  let!(:banned_visitors) do
    create_list(:visitor, 2, visit: visit)
  end

  before do
    unlisted_visitors.each do |uv|
      uv.not_on_list = true
      params[:visitors_attributes][params[:visitors_attributes].size] = uv.attributes.slice('id', 'banned', 'not_on_list')
    end
    banned_visitors.map do |bv|
      bv.banned = true
      params[:visitors_attributes][params[:visitors_attributes].size] = bv.attributes.slice('id', 'banned', 'not_on_list')
    end
  end

  let(:booking_response) { BookingResponse.new(visit: visit) }

  subject { described_class.new(booking_response) }

  describe 'with a message' do
    before do
      visit.assign_attributes(params)
      expect(booking_response).to be_valid
    end

    it 'process the request' do
      subject.process_request
      expect(visit.reference_no).to eq(params[:reference_no])
      expect(visit.slot_granted.to_s).to eq(params[:slot_granted])
      expect(visit).to be_booked
      expect(visit.banned_visitors).to eq(banned_visitors)
      expect(visit.unlisted_visitors).to eq(unlisted_visitors)
    end
  end
end
