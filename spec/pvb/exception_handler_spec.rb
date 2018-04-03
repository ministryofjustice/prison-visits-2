require 'rails_helper'
require 'pvb/exception_handler'

RSpec.describe PVB::ExceptionHandler do
  before do
    allow(Rails.configuration).to receive(:sentry_dsn).and_return(sentry_dsn)
  end

  let(:exception) { Nomis::APIError.new('something went wrong') }

  context 'when Rails.configuration.sentry_dsn is set' do
    let(:sentry_dsn) { 'something' }

    it 'sends the exception to sentry' do
      expect(Raven).to receive(:capture_exception).with(exception)

      described_class.capture_exception(exception)
    end

    context 'when passing options' do
      let(:extra_options) { { foo: :bar } }

      it 'forwards the extra options to ruby-raven' do
        expect(described_class).to receive(:capture_exception).with(exception, extra_options)

        described_class.capture_exception(exception, extra_options)
      end
    end
  end

  context 'when Rails.configuration.sentry_dsn is not set' do
    let(:sentry_dsn) { nil }

    it 'raises the exception' do
      expect(Raven).not_to receive(:capture_exception).with(exception)
      expect {
        described_class.capture_exception(exception)
      }.to raise_error exception
    end
  end
end
