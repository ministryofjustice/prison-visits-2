require 'rails_helper'
require 'shared_sendgrid_context'

RSpec.describe EmailChecker do
  subject { described_class.new(address) }

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
    end

    context 'with domain only' do
      let(:address) { '@test.example.com' }
      it_behaves_like 'an invalid address', 'unparseable'
    end

    context 'with local part only' do
      let(:address) { 'jimmy.harris' }
      it_behaves_like 'an invalid address', 'malformed'
    end

    context 'with dot at start of domain' do
      let(:address) { 'user@.test.example.com' }
      it_behaves_like 'an invalid address', 'domain_dot'
    end

    context 'with dot at end of domain' do
      let(:address) { 'user@test.example.com.' }
      it_behaves_like 'an invalid address', 'unparseable'
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

    context 'when MX check fails' do
      before do
        allow(Rails.configuration.mx_checker).
          to receive(:records?).and_return(false)
      end

      it_behaves_like 'an invalid address', 'no_mx_record'
    end
  end
end
