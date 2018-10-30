require 'rails_helper'
require 'pvb/digital_user_constraint'

RSpec.describe PVB::DigitalUserConstraint do
  let(:user) { create(:user) }
  let(:sso_data) do
    {
      'user_id' => user.id,
      'profile_url' => 'profile_url',
      'full_name' => 'John Doe',
      'logout_url' => 'logout_url',
      'permissions' => [{ 'organisation' => org }]
    }
  end

  let(:request) do
    double(ActionDispatch::Request, session: { sso_data: sso_data })
  end

  subject { described_class.new }

  describe '.matches?' do
    context 'with no user logged in' do
      let(:request) do
        double(ActionDispatch::Request, session: {})
      end

      it { is_expected.not_to be_matches(request) }
    end

    context 'with a pvb admin user' do
      let(:org) { EstateSSOMapper::DIGITAL_ORG  }

      it { is_expected.to be_matches(request) }
    end

    context 'with a non pvb admin user' do
      let(:org) { 'another.org'  }

      it { is_expected.not_to be_matches(request) }
    end
  end
end
