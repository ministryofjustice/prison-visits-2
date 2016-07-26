require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  describe '#create' do
    subject(:create) { get :create, provider: 'mojsoo' }

    let(:auth_hash) { { 'info' => anything } }

    before do
      request.env['omniauth.auth'] = auth_hash
    end

    context "when the user can't be signed in" do
      before do
        expect(User).to receive(:from_sso).and_return(nil)
      end

      it { is_expected.to redirect_to(root_path) }
    end

    context 'when the user can be signed in' do
      let(:user) { FactoryGirl.create(:user) }

      before do
        expect(User).to receive(:from_sso).and_return(user)
      end

      it 'sets the current user id in the session' do
        create
        expect(session[:current_user_id]).to eq(user.id)
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

      context 'without a redirect_path set on the session' do
        it 'redirects to the inbox by default' do
          expect(create).to redirect_to(prison_inbox_path)
        end
      end
    end
  end

  describe '#destroy' do
    subject(:destroy) { delete :destroy }

    before do
      session[:current_user_id] = 'user_id'

      allow(controller).
        to receive(:sso_link).
        with(:logout).
        and_return('http://example.com/logout')
    end

    it 'deletes the current user id from the session and redirects' do
      expect(destroy).
        to redirect_to(<<-EOS.strip_heredoc)
          http://example.com/logout?redirect_to=#{CGI.escape(root_url)}
      EOS
      expect(session[:current_user_id]).to be_nil
    end
  end
end
