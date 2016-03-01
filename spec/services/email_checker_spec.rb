require 'rails_helper'
require 'shared_sendgrid_context'

RSpec.describe EmailChecker do
  subject { described_class.new(address, override) }
  let(:override) { false }

  shared_examples 'a valid address' do
    it { is_expected.to be_valid }

    it 'has no error' do
      expect(subject.error).to be_valid
    end
  end

  shared_examples 'an invalid address' do |sym|
    it { is_expected.not_to be_valid }

    it "has the #{sym} error" do
      expect(subject.error).to eq(sym)
    end
  end

  context 'with invalid address' do
    context 'with empty string' do
      let(:address) { '' }
      it_behaves_like 'an invalid address', 'malformed'
      it { is_expected.not_to be_delivery_error_occurred }
      it { is_expected.not_to be_reset_spam_report }
      it { is_expected.not_to be_reset_bounce }
    end

    context 'with domain only' do
      let(:address) { '@test.example.com' }
      it_behaves_like 'an invalid address', 'unparseable'
      it { is_expected.not_to be_delivery_error_occurred }
    end

    context 'with local part only' do
      let(:address) { 'jimmy.harris' }
      it_behaves_like 'an invalid address', 'malformed'
      it { is_expected.not_to be_delivery_error_occurred }
    end

    context 'with dot at start of domain' do
      let(:address) { 'user@.test.example.com' }
      it_behaves_like 'an invalid address', 'domain_dot'
      it { is_expected.not_to be_delivery_error_occurred }
    end

    context 'with dot at end of domain' do
      let(:address) { 'user@test.example.com.' }
      it_behaves_like 'an invalid address', 'unparseable'
      it { is_expected.not_to be_delivery_error_occurred }
    end
  end

  context 'with valid address' do
    let(:address) { 'user@test.example.com' }

    it_behaves_like 'a valid address'

    it 'checks MX record only once' do
      expect(Rails.configuration.mx_checker).
        to receive(:records?).once.and_return(true)

      2.times do
        subject.valid?
      end
    end

    it 'checks Sendgrid only once' do
      expect(SendgridApi).to receive(:spam_reported?).once.and_return(false)
      expect(SendgridApi).to receive(:bounced?).once.and_return(false)

      2.times do
        subject.valid?
      end
    end

    context 'when MX check fails' do
      before do
        allow(Rails.configuration.mx_checker).
          to receive(:records?).and_return(false)
      end

      it_behaves_like 'an invalid address', 'no_mx_record'
      it { is_expected.not_to be_delivery_error_occurred }
    end

    context 'when spam is reported' do
      include_context 'sendgrid reports spam'

      it { is_expected.to be_delivery_error_occurred }

      context 'and override is not set' do
        it_behaves_like 'an invalid address', 'spam_reported'
        it { is_expected.not_to be_reset_spam_report }
      end

      context 'but override is set by a parameter' do
        let(:override) { true }
        it_behaves_like 'a valid address'
        it { is_expected.to be_reset_spam_report }
      end

      context 'but sendgrid validations are disabled' do
        before do
          allow(Rails.configuration).
            to receive(:enable_sendgrid_validations).
            and_return(false)
        end
        it_behaves_like 'a valid address'
      end
    end

    context 'when bounce is reported' do
      include_context 'sendgrid reports a bounce'

      it { is_expected.to be_delivery_error_occurred }

      context 'and override is not set' do
        it_behaves_like 'an invalid address', 'bounced'
        it { is_expected.not_to be_reset_bounce }
      end

      context 'but override is set by a paramenter' do
        let(:override) { true }
        it_behaves_like 'a valid address'
        it { is_expected.to be_reset_bounce }
      end

      context 'but sendgrid validations are disabled' do
        before do
          allow(Rails.configuration).
            to receive(:enable_sendgrid_validations).
            and_return(false)
        end
        it_behaves_like 'a valid address'
      end
    end
  end
end
