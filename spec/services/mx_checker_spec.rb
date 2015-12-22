require 'rails_helper'

RSpec.describe MxChecker do
  subject { described_class.new(resolver) }
  let(:resolver) { double('Resolv::DNS') }
  let(:domain) { 'test.example.com' }

  before do
    allow(Resolv::DNS).to receive(:new).and_return(resolver)
  end

  describe 'records?' do
    context 'when MX records are found' do
      before do
        allow(resolver).
          to receive(:getresource).with(domain, anything).
          and_return(true)
      end

      it 'is true' do
        expect(subject.records?(domain)).to be_truthy
      end
    end

    context 'when the MX query times out' do
      before do
        allow(resolver).
          to receive(:getresource).
          and_raise(Resolv::ResolvTimeout)
      end

      it 'is true' do
        expect(subject.records?(domain)).to be_truthy
      end
    end

    context 'when the MX query fails' do
      before do
        allow(resolver).
          to receive(:getresource).
          and_raise(Resolv::ResolvError)
      end

      it 'is false' do
        expect(subject.records?(domain)).to be_falsey
      end
    end
  end
end
