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
      FactoryBot.create(:estate, sso_organisation_name: org_name)
    end

    context 'when a user has previously logged in' do
      let!(:user) { FactoryBot.create(:user, email: oauth_info['email']) }

      context 'when they have no permissions' do
        let(:permissions) { [] }

        it 'rejects the login attempt' do
          expect(from_omniauth).to be_nil
        end
      end

      context 'when they have permissions to access only unknown-to-pvb organisations' do
        let(:permissions) {
          [{ 'organisation' => 'not-an-estate', 'roles' => [] }]
        }

        it 'rejects the login attempt' do
          expect(from_omniauth).to be_nil
        end
      end

      context 'when they have permission to access an org linked to a pvb estate' do
        let(:permissions) {
          [{ 'organisation' => org_name, 'roles' => [] }]
        }

        it 'accepts the login' do
          expect(from_omniauth.user).to eq(user)
        end
      end
    end

    context 'with a user has not previously logged in' do
      context 'with no permissions' do
        let(:permissions) { [] }

        it 'rejects the login attempt' do
          expect(from_omniauth).to be_nil
        end
      end

      context 'when they have permissions to access only unknown-to-pvb organisations' do
        let(:permissions) {
          [{ 'organisation' => 'random', 'roles' => [] }]
        }

        it 'rejects the login attempt' do
          expect(from_omniauth).to be_nil
        end
      end

      context 'when they have permission to access an org linked to a pvb estate' do
        let(:permissions) {
          [{ 'organisation' => org_name, 'roles' => [] }]
        }

        it 'creates a new user' do
          expect { from_omniauth }.to change {
            User.where(email: oauth_info['email']).count
          }.by(1)
        end

        it 'returns a signon identity' do
          expect(from_omniauth.full_name).to eq('Joe Bloggs')
        end
      end
    end
  end

  describe 'saving and restoring from session data' do
    let!(:user) { create(:user) }
    let!(:serialization) do
      {
        'user_id' => user.id,
        'full_name' => "Mr A",
        'profile_url' => 'https://example.com/profile',
        'logout_url' => 'https://example.com/logout',
        'permissions' => [{ 'organisation' => 'noms', 'roles' => [] }]
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

  describe 'instance' do
    let!(:user)               { create(:user) }
    let!(:cardiff_org_name)   { 'cardiff.noms' }
    let!(:cardiff_estate)     { create(:estate, sso_organisation_name: cardiff_org_name, nomis_id: 'CFI') }
    let!(:pentonville_estate) { create(:estate, sso_organisation_name: 'pentonville.noms') }
    let!(:swansea_org_name)   { 'swansea.noms' }
    let!(:swansea_estate)     { create(:estate, sso_organisation_name: swansea_org_name, nomis_id: 'SWI') }
    let!(:orgs)               { [swansea_org_name, cardiff_org_name] }
    let!(:serialization) do
      {
        'user_id' => user.id,
        'full_name' => "Mr A",
        'profile_url' => 'https://example.com/profile',
        'logout_url' => 'https://example.com/logout',
        'permissions' => orgs.map { |o| { 'organisation' => o, 'roles' => [] } }
      }
    end

    subject { described_class.from_session_data(serialization) }

    around do |ex|
      EstateSSOMapper.reset_grouped_estates
      ex.run
      EstateSSOMapper.reset_grouped_estates
    end

    it 'makes available the list of accessible estates' do
      expect(subject.accessible_estates).to contain_exactly(cardiff_estate, swansea_estate)
      expect(subject.accessible_estates).not_to include(pentonville_estate)
    end

    it 'allows checking whether all the estates is accessible' do
      expect(subject.accessible_estates?([cardiff_estate])).to be true
      expect(subject.accessible_estates?([pentonville_estate])).to be false
      expect(subject.accessible_estates?([cardiff_estate, pentonville_estate])).
        to be false
    end

    context 'with #default_estates' do
      it 'determines the default estates for a user' do
        expect(subject.default_estates).to contain_exactly(cardiff_estate, swansea_estate)
      end

      context 'when an admin' do
        let!(:orgs) { [EstateSSOMapper::DIGITAL_ORG] }

        it 'defaults to only 1 estate' do
          expect(subject.default_estates.size).to eq(1)
        end
      end
    end

    it 'builds the logout url required for SSO' do
      expect(
        subject.logout_url(redirect_to: 'https://pvb/loggedout')
      ).to eq(
        'https://example.com/logout?redirect_to=https%3A%2F%2Fpvb%2Floggedout'
      )
    end

    context 'when a user is associated to a digital team' do
      let!(:orgs) { [swansea_org_name, 'digital.noms.moj'] }

      it 'makes all estates accessible' do
        expect(subject.accessible_estates).to include(pentonville_estate)
      end
    end
  end
end
