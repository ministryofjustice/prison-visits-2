require 'rails_helper'
RSpec.describe OmniAuth::Strategies::Mojsso do
  let(:app){
    Rack::Builder.new do |b|
      b.run ->(_env) { [200, {}, ['Hello']] }
    end.to_app
  }

  subject(:strategy) do
    described_class.new(app, 'client_id', 'secret')
  end

  context 'when methods' do
    let(:uid) { double('uid') }
    let(:first_name) { double('first_name') }
    let(:last_name) { double('last_name') }
    let(:email) { FFaker::Internet.email }
    let(:permissions) { double('permissions') }
    let(:links) { double('links') }

    let(:raw_info) do
      {
        'id' => uid,
        'first_name' => first_name,
        'last_name' => last_name,
        'email' => email,
        'permissions' => permissions,
        'links' => links
      }
    end

    context 'when #info' do
      before do
        allow(strategy).to receive(:raw_info).and_return(raw_info)
      end

      it 'returns a hash with the email and permissions' do
        expect(strategy.info).to eq(
          first_name: first_name,
          last_name: last_name,
          email: email,
          permissions: permissions,
          links: links)
      end
    end

    context 'when #extra' do
      before do
        allow(strategy).to receive(:raw_info).and_return(raw_info)
      end

      it { expect(strategy.extra).to eq(raw_info: raw_info) }
    end

    context 'when #uid' do
      before do
        allow(strategy).to receive(:raw_info).and_return(raw_info)
      end

      it { expect(strategy.uid).to eq(uid) }
    end

    context 'when #raw_info' do
      let(:token) { double('token') }
      let(:api_response) { double('api_response') }

      before do
        allow(strategy).to receive(:access_token).and_return(token)
      end

      it 'makes a call to the api and parses' do
        expect(token).
          to receive(:get).with('/api/user_details').and_return(api_response)
        expect(api_response).to receive(:parsed).and_return(raw_info)

        expect(strategy.raw_info).to eq(raw_info)
      end
    end
  end
end
