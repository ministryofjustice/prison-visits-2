require 'rails_helper'

RSpec.describe Api::VisitsController do
  render_views

  let(:visit)    { create(:visit) }
  let(:prison)   do
    create(
      :prison,
      slot_details: { 'recurring' => { 'mon' => ['1330-1430'] } }
    )
  end

  let(:parsed_body) {
    JSON.parse(response.body)
  }

  around do |example|
    travel_to Time.zone.local(2016, 2, 3, 14, 0) do
      example.run
    end
  end

  before do
    allow(GATracker)
      .to receive(:new)
           .and_return(double(GATracker,
                              send_withdrawn_visit_event: nil,
                              send_cancelled_visit_event: nil))
  end

  describe 'create' do
    let(:params) {
      {
        format: :json,
        prison_id: prison.id,
        prisoner: {
          first_name: 'Joe',
          last_name: 'Bloggs',
          date_of_birth: '1980-01-01',
          number: 'A1234BC'
        },
        visitors: [
          {
            first_name: 'Joe',
            last_name: 'Bloggs',
            date_of_birth: '1980-01-01'
          }
        ],
        slot_options: [
          '2016-02-15T13:30/14:30'
        ],
        contact_email_address: 'foo@example.com',
        contact_phone_no: '1234567890'
      }
    }

    describe 'when sucessfull' do
      specify do
        expect(post :create, params:).to render_template(:show)
      end

      it 'creates a new visit booking request' do
        expect { post :create, params: }.to change(Visit, :count).by(1)

        expect(response).to have_http_status(:ok)
        expect(parsed_body['visit']).to have_key('id')
        expect(parsed_body['visit']['processing_state']).to eq('requested')
      end

      it 'sets the locale of the visit if Accept-Language header sent' do
        request.headers['Accept-Language'] = 'cy'
        expect { post :create, params: }.to change(Visit, :count).by(1)
        expect(Visit.last.locale).to eq('cy')
      end
    end

    it 'fails if a (top-level) parameter is missing' do
      params.delete(:contact_email_address)
      post(:create, params:)
      expect(response).to have_http_status(:unprocessable_entity)
      expect(parsed_body['message'])
        .to eq('Missing parameter: contact_email_address')
    end

    it 'fails if the prisoner is invalid' do
      params[:prisoner][:first_name] = nil
      post(:create, params:)
      expect(response).to have_http_status(:unprocessable_entity)
      expect(parsed_body['message'])
        .to eq('Invalid parameter: prisoner (First name is required)')
    end

    it 'fails if the visitors are invalid' do
      params[:visitors][0][:first_name] = nil
      post(:create, params:)
      expect(response).to have_http_status(:unprocessable_entity)
      expect(parsed_body['message'])
        .to eq('Invalid parameter: visitors ()')
    end

    it 'fails if slot_options is not an array' do
      params[:slot_options] = 'string'
      post(:create, params:)
      expect(response).to have_http_status(:unprocessable_entity)
      expect(parsed_body['message'])
        .to eq('Invalid parameter: slot_options must contain >= slot')
    end

    it 'fails if slot_options does not contain at least 1 slot' do
      params[:slot_options] = 'string'
      post(:create, params:)
      expect(response).to have_http_status(:unprocessable_entity)
      expect(parsed_body['message'])
        .to eq('Invalid parameter: slot_options must contain >= slot')
    end

    it 'returns an error if the slot does not exist' do
      params[:slot_options] = ['2016-02-15T04:00/04:30']
      post(:create, params:)
      expect(response).to have_http_status(:unprocessable_entity)
      expect(parsed_body['message'])
        .to match(/Invalid parameter: slot_options \(Option 0/)
    end
  end

  describe 'show' do
    let(:params) do
      {
        format: :json,
        id: visit.human_id
      }
    end

    it { expect(get :show, params:).to render_template(:show) }

    it 'returns visit status' do
      get(:show, params:)
      expect(response).to have_http_status(:ok)
      expect(parsed_body['visit']['processing_state']).to eq('requested')
    end

    context 'with a passed visit' do
      let(:visit) do
        create(
          :booked_visit,
          slot_granted: ConcreteSlot.new(2015, 11, 6, 16, 0, 17, 0)
        )
      end

      it 'returns visit status' do
        get(:show, params:)
        expect(response).to have_http_status(:ok)
        expect(parsed_body['visit']['can_cancel']).to eq(false)
      end
    end

    context 'with a booked visit' do
      let(:visit) do
        create(
          :booked_visit,
          slot_granted: ConcreteSlot.new(2015, 11, 6, 16, 0, 17, 0)
        )
      end

      it 'returns visit status' do
        get(:show, params:)
        expect(response).to have_http_status(:ok)
        expect(parsed_body['visit']['can_withdraw']).to eq(false)
      end
    end

    context 'with messages' do
      let!(:message) { create(:message, visit:) }

      it 'returns a list of messages' do
        get(:show, params:)
        expect(parsed_body['visit']['messages'])
          .to eq([{ 'body' => message.body }])
      end
    end

    it 'fails if the visit does not exist' do
      params[:id] = '123'
      get(:show, params:)
      expect(response).to have_http_status(:not_found)
      expect(parsed_body['message']).to eq('Not found')
    end

    context 'with a guid' do
      let(:params) do
        {
          format: :json,
          id: visit.id
        }
      end

      it { expect(get :show, params:).to render_template(:show) }
    end
  end

  describe 'destroy' do
    let(:params) {
      {
        format: :json,
        id: visit.human_id
      }
    }

    let(:mailing) {
      double(Mail::Message, deliver_later: nil)
    }

    specify do expect(delete :destroy, params:).to render_template(:show) end

    context 'with a booked visit' do
      let(:visit) { create(:booked_visit) }

      it 'cancels a visit request' do
        delete(:destroy, params:)
        expect(response).to have_http_status(:ok)
        expect(parsed_body['visit']['processing_state']).to eq('cancelled')
      end
    end

    context 'with a requested visit' do
      it 'withdraws the requested visit' do
        delete(:destroy, params:)
        expect(response).to have_http_status(:ok)
        expect(parsed_body['visit']['processing_state']).to eq('withdrawn')
      end

      it 'fails if the visit does not exist' do
        params[:id] = '123'
        delete(:destroy, params:)
        expect(response).to have_http_status(:not_found)
        expect(parsed_body['message']).to eq('Not found')
      end

      it 'is idempotent' do
        delete(:destroy, params:)
        expect(response).to have_http_status(:ok)
        expect(assigns(:visit).visit_state_changes.size).to eq(1)

        delete(:destroy, params:)
        expect(response).to have_http_status(:ok)
        expect(assigns(:visit).visit_state_changes.size).to eq(1)
      end
    end
  end
end
