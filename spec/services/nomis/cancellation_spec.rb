require "rails_helper"

RSpec.describe Nomis::Cancellation do
  describe '.new' do
    context 'without an error' do
      let(:attributes) { { message: 'success' } }

      it 'contains the message' do
        expect(described_class.new(attributes)).to have_attributes(message: 'success')
      end
    end

    context 'with an error' do
      let(:attributes) { { 'error' => {  'message' => 'oh nooooo!'  } } }

      it 'contains the error message' do
        expect(described_class.new(attributes)).to have_attributes(error_message: 'oh nooooo!')
      end
    end
  end
end
