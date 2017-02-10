require 'rails_helper'

RSpec.describe HttpMethodNotAllowed do
  describe '#call' do
    let(:env) { { 'REQUEST_METHOD' => request_method } }
    let(:app) { double('App') }
    subject { described_class.new(app).call(env) }

    context 'when is an allowed method' do
      let(:request_method) { 'get' }

      it 'lets the request go through' do
        expect(app).to receive(:call).with(env)
        subject
      end
    end

    context 'when is not an allowed method' do
      let(:request_method) { 'webdav' }

      it 'does not let the request go through' do
        expect(app).to_not receive(:call)
        subject
      end

      it 'responds with a 405' do
        status, env, body = subject
        expect(status).to eq(405)
        expect(env).to eq('Content-Type' => 'text/plain')
        expect(body).to eq(['Method Not Allowed'])
      end
    end
  end
end
