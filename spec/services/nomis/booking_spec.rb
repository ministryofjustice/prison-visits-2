require 'rails_helper'

RSpec.describe Nomis::Booking do
  describe '.build' do
    describe 'with a single error message' do
      let(:error_message) { 'error message' }
      let(:response) { { 'error' => { 'message' => error_message } } }

      it 'parses the error message' do
        expect(described_class.build(response)).
          to have_attributes(visit_id: nil, error_messages: [error_message])
      end
    end

    describe 'with a multiple error messages' do
      let(:error_message1) { 'error message1' }
      let(:error_message2) { 'error message2' }
      let(:response) do
        { 'errors' => [{ 'message' => error_message1 }, { 'message' => error_message2 }] }
      end

      it 'parses the error message' do
        expect(described_class.build(response)).
          to have_attributes(visit_id: nil, error_messages: [error_message1, error_message2])
      end
    end

    describe 'with a successful response' do
      let(:visit_id) { 12_345 }
      let(:response) { { 'visit_id' => visit_id } }

      it 'parses the visit id' do
        expect(described_class.build(response)).
          to have_attributes(visit_id: visit_id, error_messages: [])
      end
    end
  end
end
