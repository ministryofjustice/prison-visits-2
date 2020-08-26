require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  describe '#create' do
    subject(:create) { get :create, params: { provider: 'hmpps_sso' } }

    let(:auth_hash) { { 'info' => anything } }
    let(:sso_data) do
      {
        'user_id': 'some-user-id',
        'profile_url': 'profile_url',
        'full_name': 'John Doe',
        'logout_url': 'logout_url',
        'organisations': []
      }
    end

    before do
      request.env['omniauth.auth'] = auth_hash
    end

    context "when the user can't be signed in" do
      before do
        allow(SignonIdentity).to receive(:from_omniauth).and_return(nil)
      end

      it { is_expected.to redirect_to(root_path) }
    end

    context 'when the user can be signed in' do
      let(:signon_identity) { double(SignonIdentity, to_session: sso_data) }

      before do
        allow(SignonIdentity).to receive(:from_omniauth).and_return(signon_identity)
      end

      it 'sets the identity data in the session' do
        create
        expect(session[:sso_data]).to eq(sso_data)
      end

      context 'with a redirect_path set on the session' do
        let(:redirect_path) { '/prison/inbox' }

        before do
          session[:redirect_path] = '/prison/inbox'
        end

        it 'clears the redirect from the session and redirects' do
          expect(create).to redirect_to(redirect_path)
          expect(session[:redirect_path]).to be_nil
        end
      end

      context 'with no redirect_path set on the session' do
        it 'redirects to the inbox by default' do
          expect(create).to redirect_to(prison_inbox_path)
        end
      end
    end
  end

  describe '#destroy' do
    subject(:destroy) { delete :destroy }

    let(:user) { FactoryBot.create(:user) }
    let(:estate_nomis_id) { 'ACI' }

    let(:sso_data) do
      {
        'user_id' => user.id,
        'full_name' => 'Joe Bloggs',
        'roles' => [],
        'logout_url' => 'http://example.com/logout',
        'organisations' => [estate_nomis_id]
      }
    end

    before do
      session[:sso_data] = sso_data
      create(:estate, nomis_id: estate_nomis_id)
    end

    it 'deletes the session and does not redirect to SSO if session data invalid' do
      session[:sso_data].delete('user_id')
      expect(destroy).to redirect_to(root_url)
      expect(session[:sso_data]).to be_nil
    end

    it 'deletes the current user id from the session and redirects' do
      expect(destroy).
        to redirect_to(<<-URI.strip_heredoc)
          http://example.com/logout?redirect_to=#{CGI.escape(root_url)}
      URI
      expect(session[:sso_data]).to be_nil
    end
  end
end
