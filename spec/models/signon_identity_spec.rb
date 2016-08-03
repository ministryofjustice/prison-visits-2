require 'rails_helper'

RSpec.describe SignonIdentity, type: :model do
  describe '.from_omniauth' do
    subject(:from_omniauth) { described_class.from_omniauth(omniauth_auth) }

    let(:omniauth_auth) { { 'info' => oauth_info } }
    let(:oauth_info) do
      {
        'email' => FFaker::Internet.email,
        'permissions' => permissions,
        'first_name' => 'Joe',
        'last_name' => 'Bloggs',
        'links' => {
          'profile' => '',
          'logout' => ''
        }
      }
    end

    let(:org_name) { 'cardiff.noms' }
    let!(:estate) do
      FactoryGirl.create(:estate, sso_organisation_name: org_name)
    end

    context 'user has previously logged in' do
      let!(:user) { FactoryGirl.create(:user, email: oauth_info['email']) }

      context 'has no permissions' do
        let(:permissions) { [] }

        it 'rejects the login attempt' do
          expect(from_omniauth).to be_nil
        end
      end

      context 'has invalid permissions' do
        let(:permissions) {
          [{ 'organisation' => 'not-an-estate', 'roles' => [] }]
        }

        it 'rejects the login attempt' do
          expect(from_omniauth).to be_nil
        end
      end

      context 'has permissions to the estate' do
        let(:permissions) {
          [{ 'organisation' => org_name, 'roles' => [] }]
        }

        it 'accepts the login' do
          expect(from_omniauth.user).to eq(user)
        end
      end
    end

    context 'user has not previously logged in' do
      context 'has no permissions' do
        let(:permissions) { [] }

        it 'rejects the login attempt' do
          expect(from_omniauth).to be_nil
        end
      end

      context 'has permissions to an unknown organisation' do
        let(:permissions) {
          [{ 'organisation' => 'random', 'roles' => [] }]
        }

        it 'rejects the login attempt' do
          expect(from_omniauth).to be_nil
        end
      end

      context 'has permissions to the estate' do
        let(:permissions) {
          [{ 'organisation' => org_name, 'roles' => [] }]
        }

        it 'creates a new user' do
          expect { from_omniauth }.to change {
            User.where(email: oauth_info['email'], estate_id: estate.id).count
          }.by(1)
        end

        it 'returns a signon identity' do
          expect(subject.full_name).to eq('Joe Bloggs')
        end
      end
    end
  end

  describe 'saving and restoring from session data' do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:serialization) do
      {
        'user_id' => user.id,
        'full_name' => "Mr A",
        'profile_url' => 'https://example.com/profile',
        'logout_url' => 'https://example.com/logout'
      }
    end

    it 'can be loaded from a hash' do
      identity = described_class.from_session_data(serialization)
      expect(identity.user).to eq(user)
    end

    it 'can be serialised to a hash' do
      identity = described_class.from_session_data(serialization)
      expect(identity.to_session).to eq(serialization)
    end
  end
end
