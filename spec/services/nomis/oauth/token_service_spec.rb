require 'rails_helper'

RSpec.describe Nomis::Oauth::TokenService do
  # Ensure that we have a new instance to prevent other specs interfering
  around do |ex|
    Singleton.__init__(described_class)
    ex.run
    Singleton.__init__(described_class)
  end

  it 'fetches a new auth token if it is expired' do
    unexpired_token = Nomis::Oauth::Token.new(access_token: generate_jwt_token)
    expired_encoded_token = generate_jwt_token(exp: Time.current.to_i - 3600)
    expired_token = Nomis::Oauth::Token.new(access_token: expired_encoded_token)

    expect_any_instance_of(described_class).
        to receive(:fetch_token).
            and_return(expired_token, unexpired_token)

    token_service = described_class.instance

    expect(token_service.valid_token).to eq(unexpired_token)
  end
end
