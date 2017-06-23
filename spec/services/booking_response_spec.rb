require 'rails_helper'

RSpec.describe BookingResponse do
  describe '.successful' do
    subject { described_class.successful }

    it { is_expected.to be_success }
    it { expect(subject.message).to eq(described_class::SUCCESS) }
  end

  describe '.process_required' do
    subject { described_class.process_required }

    it { expect(subject.message).to eq(described_class::PROCESS_REQUIRED_ERROR) }
  end

  describe '.nomis_api_error' do
    subject { described_class.nomis_api_error }

    it { expect(subject.message).to eq(described_class::NOMIS_API_ERROR) }
  end

  describe '.already_processed' do
    subject { described_class.already_processed }

    it { expect(subject.message).to eq(described_class::ALREADY_PROCESSED_ERROR) }
    it { expect(subject).to be_already_processed }
  end

  describe '.nomis_validation_error' do
    subject { described_class.nomis_validation_error }

    it { expect(subject.message).to eq(described_class::NOMIS_VALIDATION_ERROR) }
  end
end
