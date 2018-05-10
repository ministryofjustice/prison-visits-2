require 'rails_helper'

RSpec.describe ZendeskClient do
  subject { Class.new }

  URL = 'https://zendesk_api.com'
  USERNAME = 'bob'
  TOKEN = '123456'

  expectations = [
    {
      config: 'url', value: URL
    },
    {
      config: 'token', value: TOKEN
    },
    {
      config: 'username', value: "#{USERNAME}/token"
    }
  ]

  before do
    set_configuration_with(:zendesk_url, URL)
    set_configuration_with(:zendesk_user, USERNAME)
    set_configuration_with(:zendesk_token, TOKEN)

    subject.extend(described_class)
  end

  describe 'a valid instance' do
    expectations.each do |expectation|
      it "has the correct #{expectation[:config]}" do
        expect(subject.client.config.send(expectation[:config])).to eq(expectation[:value])
      end
    end
  end
end
