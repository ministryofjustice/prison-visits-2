require 'rails_helper'

RSpec.describe Nomis::Booking do
  describe '.build' do
    describe 'with an error response' do
      let(:error_message) { 'error message' }
      let(:response) { { 'error' => { 'message' => error_message } } }

      it 'parses the error message' do
        expect(described_class.build(response)).
          to have_attributes(visit_id: nil, error_message: error_message)
      end
    end

    describe 'with a successful response' do
      let(:visit_id) { 12_345 }
      let(:response) { { 'visit_id' => visit_id } }

      it 'parses the visit id' do
        expect(described_class.build(response)).
          to have_attributes(visit_id: visit_id, error_message: nil)
      end
    end
  end
end
