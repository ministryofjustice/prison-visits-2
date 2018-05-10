require 'rails_helper'

RSpec.describe ZendeskClient do
  subject { Class.new }

  let(:url) { 'https://zendesk_api.com' }
  let(:username) { 'bob' }
  let(:token) { '123456' }

  before do
    set_configuration_with(:zendesk_url, url)
    set_configuration_with(:zendesk_user, username)
    set_configuration_with(:zendesk_token, token)

    subject.extend(described_class)
  end

  describe 'a valid instance' do
    it 'has a zendesk url' do
      expect(client_config.url).to eq(url)
    end

    it 'has a zendesk username' do
      expect(client_config.username).to eq("#{username}/token")
    end

    it 'has a zendesk token' do
      expect(client_config.token).to eq(token)
    end
  end

  def client_config
    subject.client.config
  end
end
