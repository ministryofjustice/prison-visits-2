require 'rails_helper'

class DummyVSiPReturn
  def body
    [:LEI].to_json
  end
end


RSpec.describe Vsip::Client do
  subject { described_class.new(api_host) }

  let(:api_host) { Rails.configuration.vsip_host }

  let(:path) { '/config/prisons/supported' }

  describe 'with a valid request' do
    before do
      allow_any_instance_of(Excon::Connection).to receive(:request).and_return(DummyVSiPReturn.new)
    end

    it 'get list of supported prisons' do
      expect(subject.get(path)).to eq(["LEI"])
    end
  end

  context 'when there is an http status error' do
    let(:error) do
      Excon::Error::HTTPStatus.new('error',
                                   double('request'),
                                   double('response', status: 422, body: '<html>'))
    end

    before do
      WebMock.stub_request(:get, /\w/).to_raise(error)
    end

    it 'raises an APIError', :expect_exception do
      expect { subject.get(path) }
        .to raise_error(Vsip::APIError, 'Unexpected status 422 calling GET /config/prisons/supported: (invalid-JSON) <html>')
    end

    it 'sends the error to sentry' do
      expect(PVB::ExceptionHandler).to receive(:capture_exception).with(error, fingerprint: %w[vsip excon])

      expect { subject.get(path) }.to raise_error(Vsip::APIError)
    end
  end

  context 'when there is a timeout' do
    before do
      WebMock.stub_request(:get, /\w/).to_timeout
    end

    it 'raises an Vsip::TimeoutError if a timeout occurs', :expect_exception do
      expect {
        subject.get(path)
      }.to raise_error(Vsip::APIError)
    end
  end

  context 'when there is an unexpected exception' do
    let(:error) do
      Excon::Errors::SocketError.new(StandardError.new('Socket error'))
    end

    before do
      WebMock.stub_request(:get, /\w/).to_raise(error)
    end

    it 'raises an APIError if an unexpected exception is raised containing request information', :expect_exception do
      expect {
        subject.get(path)
      }.to raise_error(Vsip::APIError)
    end
  end

  describe 'with an error' do
    let(:error) do
      Excon::Error::HTTPStatus.new('error',
                                   double('request'),
                                   double('response', status: 422, body: '<html>'))
    end

    before do
      WebMock.stub_request(:get, /\w/).to_raise(error)
    end

    it 'raises an APIError if an unexpected exception is raised containing request information', :expect_exception do
      expect {
        subject.get(path)
      }.to raise_error(Vsip::APIError, 'Unexpected status 422 calling GET /config/prisons/supported: (invalid-JSON) <html>')
    end

    it 'sends the error to sentry' do
      expect(PVB::ExceptionHandler).to receive(:capture_exception).with(error, fingerprint: %w[vsip excon])

      expect { subject.get(path) }.to raise_error(Vsip::APIError)
    end
  end

  describe 'param options' do
    it 'return params if not empty' do
      expect(Vsip::Client.new(Rails.configuration.vsip_host).send(:params_options, :method, :params)).to eq({:query=>:params})
    end
  end
end
