require "rails_helper"

RSpec.describe BookingResponder::Accept do
  include_context 'with staff response setup'

  let!(:unlisted_visitors) do
    create_list(:visitor, 2, visit: visit)
  end

  let!(:banned_visitors) do
    create_list(:visitor, 2, visit: visit)
  end

  let(:staff_response) { StaffResponse.new(visit: visit, user: create(:user)) }

  before do
    unlisted_visitors.each do |uv|
      uv.not_on_list = true
      params[:visitors_attributes][params[:visitors_attributes].size] = uv.attributes.slice('id', 'banned', 'not_on_list')
    end
    banned_visitors.each do |bv|
      bv.banned = true
      params[:visitors_attributes][params[:visitors_attributes].size] = bv.attributes.slice('id', 'banned', 'not_on_list')
    end
  end

  subject { described_class.new(staff_response) }

  shared_examples_for 'process the request' do
    it 'updates the visit' do
      subject.process_request
      expect(visit.reference_no).to eq(params[:reference_no])
      expect(visit.slot_granted.to_s).to eq(params[:slot_granted])
      expect(visit).to be_booked
      expect(visit.banned_visitors).to eq(banned_visitors)
      expect(visit.unlisted_visitors).to eq(unlisted_visitors)
    end
  end

  before do
    visit.assign_attributes(params)
  end

  describe 'accepting the request' do
    it_behaves_like 'process the request'
  end
end
