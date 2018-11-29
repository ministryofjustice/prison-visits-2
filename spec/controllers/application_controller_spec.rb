require "rails_helper"
require 'nomis/client'

RSpec.describe ApplicationController, type: :controller do
  let(:user) { create(:user) }

  controller do
    def index
      head :ok
    end

    def create
      Nomis::Api.instance.lookup_active_prisoner(
        noms_id: 'Z9999ZZ',
        date_of_birth: '1976-06-12'
      )
      head :ok
    end
  end

  describe '#set_locale' do
    context 'with an invalid locale' do
      it 'defaults to en' do
        expect {
          get :index, params: { locale: 'ent' }
        }.not_to raise_error
      end
    end
  end

  describe '#log_api_calls' do
    it 'logs api calls', :expect_exception do
      WebMock.stub_request(:get, /\w/).to_return(status: 500)
      post :create
      expect(PVB::Instrumentation.custom_log_items[:api_request_count]).to eq(1)
      expect(PVB::Instrumentation.custom_log_items[:api_retry_count]).to eq(1)
      expect(PVB::Instrumentation.custom_log_items[:api_error_count]).to eq(2)
    end
  end

  describe '#current_estates' do
    subject(:current_estates) { controller.current_estates }

    let(:estate)  { create(:estate) }
    let(:estate2) { create(:estate) }

    let(:uuid) { 'some-uuid' }

    before do
      # ugly hack to ensure the uuid is returned
      # there is currently no way to set headers on controller test with Rails 5.1
      # and the request object accessible from rspec-rails is a different
      # instance than the on the ApplicationController has access to during the test,
      # so it not possible to only stub this request.
      allow_any_instance_of(ActionDispatch::TestRequest).to receive(:uuid).and_return(uuid)

      login_user(user, current_estates: [estate], available_estates: [estate])
    end

    it 'returns the current_estate if set' do
      login_user(user, current_estates: [estate])
      expect(current_estates).to eq([estate])
    end

    it 'verifies that the current estate is available to the user, returning the default estate if not' do
      login_user(user, current_estates: [estate2], available_estates: [estate])
      expect(current_estates).to eq([estate])
    end

    it 'appends the current estate id, request uuid to and user id logs' do
      login_user(user, current_estates: [estate])
      get :index
      expect(PVB::Instrumentation.custom_log_items[:request_id]).to eq(uuid)
      expect(PVB::Instrumentation.custom_log_items[:estate_ids]).to eq([estate.id])
      expect(PVB::Instrumentation.custom_log_items[:user_id]).to eq(user.id)
    end

    it 'returns the default estate if a current_estate is not set' do
      login_user(user, current_estates: [estate])
      controller.session.delete(:current_estates)
      expect(current_estates).to eq([estate])
    end

    it 'returns the default estates if the current_estate does not exist' do
      login_user(user, current_estates: [estate])
      controller.session[:current_estates] = ['missing_id']
      expect(current_estates).to eq([estate])
    end
  end
end
