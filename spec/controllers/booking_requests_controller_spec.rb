require 'rails_helper'

RSpec.describe BookingRequestsController do
  let(:prisoner_details) {
    {
      first_name: 'Oscar',
      last_name: 'Wilde',
      date_of_birth: {
        day: '31',
        month: '12',
        year: '1980'
      },
      number: 'a1234bc',
      prison_id: 1
    }
  }

  let(:visitors_details) {
    {
      email_address: 'ada@test.example.com',
      phone_no: '01154960222',
      visitors_attributes: {
        '0' => {
          first_name: 'Ada',
          last_name: 'Lovelace',
          date_of_birth: {
            day: '30',
            month: '11',
            year: '1970'
          }
        }
      }
    }
  }

  let(:slots_details) {
    {
      option_0: '2015-01-02T09:00/10:00',
      option_1: '2015-01-03T09:00/10:00',
      option_2: '2015-01-04T09:00/10:00'
    }
  }

  let(:confirmation_details) {
    { confirmed: 'true' }
  }

  let(:prison) {
    double(
      Prison,
      available_slots: [
        ConcreteSlot.new(2015, 1, 2, 9, 0, 10, 0),
        ConcreteSlot.new(2015, 1, 3, 9, 0, 10, 0),
        ConcreteSlot.new(2015, 1, 4, 9, 0, 10, 0)
      ],
      validate_visitor_ages_on: nil
    )
  }

  before do
    allow(Prison).to receive(:find_by).with(id: '1').and_return(prison)
  end

  context 'on the first prisoner details page' do
    before do
      get :index, locale: 'en'
    end

    it 'assigns a new PrisonerStep' do
      expect(assigns(:steps)[:prisoner_step]).to be_a(PrisonerStep)
    end

    it 'renders the prisoner template' do
      expect(response).to render_template('prisoner_step')
    end
  end

  context 'with an unknown format' do
    subject do
      lambda {
        get :index, locale: 'en', format: 'random'
      }
    end

    it { is_expected.to raise_error(ActionController::UnknownFormat) }
  end

  context 'passing a hash as the prison_id' do
    before do
      allow(Prison).to receive(:find_by).and_call_original
    end

    subject do
      lambda {
        post :create,
          prisoner_step: { prison_id: { admin: true } },
          locale: 'en'
      }
    end

    it { is_expected.to_not raise_error }
  end

  context 'after submitting prisoner details' do
    context 'with missing prisoner details' do
      before do
        post :create,
          prisoner_step: { first_name: 'Oscar' },
          locale: 'en'
      end

      it 'renders the prisoner template' do
        expect(response).to render_template('prisoner_step')
      end

      it 'assigns a PrisonerStep' do
        expect(assigns(:steps)[:prisoner_step]).to be_a(PrisonerStep)
      end

      it 'initialises the PrisonerStep with the supplied attributes' do
        expect(assigns(:steps)[:prisoner_step]).
          to have_attributes(first_name: 'Oscar')
      end
    end

    context 'with complete prisoner details' do
      before do
        post :create,
          prisoner_step: prisoner_details,
          locale: 'en'
      end

      it 'renders the visitors template' do
        expect(response).to render_template('visitors_step')
      end

      it 'assigns a PrisonerStep' do
        expect(assigns(:steps)[:prisoner_step]).to be_a(PrisonerStep)
      end

      it 'initialises the PrisonerStep with the supplied attributes' do
        expect(assigns(:steps)[:prisoner_step]).
          to have_attributes(first_name: 'Oscar')
      end

      it 'assigns a new VisitorsStep' do
        expect(assigns(:steps)[:visitors_step]).to be_a(VisitorsStep)
      end
    end
  end

  context 'after submitting visitor details' do
    context 'with missing visitor details' do
      before do
        post :create,
          prisoner_step: prisoner_details,
          visitors_step: { phone_no: '01154960222' },
          locale: 'en'
      end

      it 'renders the visitors template' do
        expect(response).to render_template('visitors_step')
      end

      it 'assigns a PrisonerStep' do
        expect(assigns(:steps)[:prisoner_step]).to be_a(PrisonerStep)
      end

      it 'initialises the PrisonerStep with the supplied attributes' do
        expect(assigns(:steps)[:prisoner_step]).
          to have_attributes(first_name: 'Oscar')
      end

      it 'assigns a VisitorsStep' do
        expect(assigns(:steps)[:visitors_step]).to be_a(VisitorsStep)
      end

      it 'initialises the VisitorsStep with the supplied attributes' do
        expect(assigns(:steps)[:visitors_step]).
          to have_attributes(phone_no: '01154960222')
      end
    end

    context 'with complete visitor details' do
      before do
        post :create,
          prisoner_step: prisoner_details,
          visitors_step: visitors_details,
          locale: 'en'
      end

      it 'renders the slots template' do
        expect(response).to render_template('slots_step')
      end

      it 'assigns a PrisonerStep' do
        expect(assigns(:steps)[:prisoner_step]).to be_a(PrisonerStep)
      end

      it 'initialises the PrisonerStep with the supplied attributes' do
        expect(assigns(:steps)[:prisoner_step]).
          to have_attributes(first_name: 'Oscar')
      end

      it 'assigns a VisitorsStep' do
        expect(assigns(:steps)[:visitors_step]).to be_a(VisitorsStep)
      end

      it 'initialises the VisitorsStep with the supplied attributes' do
        expect(assigns(:steps)[:visitors_step]).
          to have_attributes(phone_no: '01154960222')
      end

      it 'assigns a slots step' do
        expect(assigns(:steps)[:slots_step]).to be_a(SlotsStep)
      end
    end
  end

  context 'after submitting slot details' do
    context 'with at least one slot' do
      before do
        post :create,
          prisoner_step: prisoner_details,
          visitors_step: visitors_details,
          slots_step: slots_details,
          locale: 'en'
      end

      it 'renders the confirmation template' do
        expect(response).to render_template('confirmation_step')
      end

      it 'assigns a PrisonerStep' do
        expect(assigns(:steps)[:prisoner_step]).to be_a(PrisonerStep)
      end

      it 'initialises the PrisonerStep with the supplied attributes' do
        expect(assigns(:steps)[:prisoner_step]).
          to have_attributes(first_name: 'Oscar')
      end

      it 'assigns a VisitorsStep' do
        expect(assigns(:steps)[:visitors_step]).to be_a(VisitorsStep)
      end

      it 'initialises the VisitorsStep with the supplied attributes' do
        expect(assigns(:steps)[:visitors_step]).
          to have_attributes(phone_no: '01154960222')
      end

      it 'assigns a slots step' do
        expect(assigns(:steps)[:slots_step]).to be_a(SlotsStep)
      end

      it 'initialises the SlotsStep with the supplied attributes' do
        expect(assigns(:steps)[:slots_step]).
          to have_attributes(option_0: '2015-01-02T09:00/10:00')
      end
    end

    context 'with no slots selected' do
      before do
        post :create,
          prisoner_step: prisoner_details,
          visitors_step: visitors_details,
          slots_step: { option_0: '' },
          locale: 'en'
      end

      it 'renders the slots template' do
        expect(response).to render_template('slots_step')
      end

      it 'assigns a PrisonerStep' do
        expect(assigns(:steps)[:prisoner_step]).to be_a(PrisonerStep)
      end

      it 'initialises the PrisonerStep with the supplied attributes' do
        expect(assigns(:steps)[:prisoner_step]).
          to have_attributes(first_name: 'Oscar')
      end

      it 'assigns a VisitorsStep' do
        expect(assigns(:steps)[:visitors_step]).to be_a(VisitorsStep)
      end

      it 'initialises the VisitorsStep with the supplied attributes' do
        expect(assigns(:steps)[:visitors_step]).
          to have_attributes(phone_no: '01154960222')
      end

      it 'assigns a slots step' do
        expect(assigns(:steps)[:slots_step]).to be_a(SlotsStep)
      end
    end
  end

  context 'after confirming' do
    let(:params) {
      {
        prisoner_step: prisoner_details,
        visitors_step: visitors_details,
        slots_step: slots_details,
        confirmation_step: confirmation_details,
        locale: 'en'
      }
    }

    let(:booking_request_creator) {
      double(BookingRequestCreator)
    }

    before do
      allow(BookingRequestCreator).to receive(:new).
        and_return(booking_request_creator)
      allow(booking_request_creator).to receive(:create!)
    end

    it 'renders the completed template' do
      post :create, params
      expect(response).to render_template('completed')
    end

    it 'tells BookingRequestCreator to create a Visit record' do
      expect(booking_request_creator).
        to receive(:create!).
        with(
          an_object_having_attributes(
            prison_id: 1,
            first_name: 'Oscar',
            last_name: 'Wilde',
            date_of_birth: Date.new(1980, 12, 31),
            number: 'a1234bc'
          ),
          an_object_having_attributes(
            email_address: 'ada@test.example.com',
            phone_no: '01154960222',
            visitors: [
              an_object_having_attributes(
                first_name: 'Ada',
                last_name: 'Lovelace',
                date_of_birth: Date.new(1970, 11, 30)
              )
            ]
          ),
          an_object_having_attributes(
            option_0: '2015-01-02T09:00/10:00',
            option_1: '2015-01-03T09:00/10:00',
            option_2: '2015-01-04T09:00/10:00'
          ),
          :en
        )
      post :create, params
    end
  end
end
