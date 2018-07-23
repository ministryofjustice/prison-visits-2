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

  describe '.visit_not_found' do
    subject { described_class.visit_not_found }

    it { expect(subject.message).to eq(described_class::VISIT_NOT_FOUND) }
  end

  describe '.visit_already_cancelled' do
    subject { described_class.visit_already_cancelled }

    it { expect(subject.message).to eq(described_class::VISIT_ALREADY_CANCELLED) }
  end

  describe '.visit_completed' do
    subject { described_class.visit_completed }

    it { expect(subject.message).to eq(described_class::VISIT_COMPLETED) }
  end

  describe '.invalid_cancellation_code' do
    subject { described_class.invalid_cancellation_code }

    it { expect(subject.message).to eq(described_class::INVALID_CANCELLATION_CODE) }
  end
end
