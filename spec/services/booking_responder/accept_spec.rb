require "rails_helper"

RSpec.describe BookingResponder::Accept do
  include_context 'staff response setup'

  let!(:unlisted_visitors) do
    create_list(:visitor, 2, visit: visit)
  end

  let!(:banned_visitors) do
    create_list(:visitor, 2, visit: visit)
  end

  let(:staff_response) { StaffResponse.new(visit: visit) }

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

  subject { described_class.new(staff_response, persist_to_nomis: persist_to_nomis) }

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

  describe 'with not booking to nomis' do
    let(:persist_to_nomis) { false }

    it_behaves_like 'process the request'
  end

  describe 'with book to nomis enabled' do
    let(:persist_to_nomis) { true }
    let(:nomis_visit_creator) { instance_double(CreateNomisVisit, nomis_visit_id: 12_345) }

    before do
      mock_service_with(CreateNomisVisit, nomis_visit_creator)
    end

    describe 'with book to nomis successfully' do
      before do
        expect(nomis_visit_creator).to receive(:execute).and_return(BookingResponse.successful)
      end

      it 'book the visit to nomis and update the nomis id' do
        expect {
          subject.process_request
        }.to change { visit.reload.nomis_id }.to(nomis_visit_creator.nomis_visit_id)
      end

      it_behaves_like 'process the request'
    end

    describe 'with book to nomis with errors' do
      before do
        expect(nomis_visit_creator).to receive(:execute).and_return(BookingResponse.nomis_api_error)
      end

      it 'book the visit to nomis and update the nomis id' do
        expect { subject.process_request }.not_to change { visit.reload.nomis_id }
      end

      it_behaves_like 'process the request'
    end
  end
end
