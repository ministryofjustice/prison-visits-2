require 'rails_helper'

RSpec.describe Nomis::Oauth::Token, model: true do
  it 'can confirm if it is not expired' do
    access_token = generate_jwt_token
    token = described_class.new(access_token:, expires_in: 4.hours)

    expect(token).not_to be_expired
  end

  it 'can confirm if it is expired' do
    access_token = generate_jwt_token('exp' => 4.hours.ago.to_i)
    token = described_class.new(access_token:, expires_in: -4.hours)

    expect(token.expired?).to be(true)
  end

  it 'can retrieve the payload directly' do
    access_token = generate_jwt_token('exp' => 4.hours.from_now.to_i)
    token = described_class.new(access_token:, expires_in: 4.hours)

    expect(token.expired?).to be(false)
  end
end
