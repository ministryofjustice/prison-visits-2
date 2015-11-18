require 'rails_helper'

RSpec.describe StepsController do
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
      first_name: 'Ada',
      last_name: 'Lovelace',
      date_of_birth: {
        day: '30',
        month: '11',
        year: '1970'
      },
      email_address: 'ada@test.example.com',
      phone_no: '01154960222'
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
      ]
    )
  }

  before do
    allow(Prison).to receive(:find_by).with(id: '1').and_return(prison)
  end

  context 'on the first prisoner details page' do
    before do
      get :index
    end

    it 'assigns a new PrisonerStep' do
      expect(assigns(:steps)[:prisoner_step]).to be_a(PrisonerStep)
    end

    it 'renders the prisoner template' do
      expect(response).to render_template('prisoner_step')
    end
  end

  context 'after submitting prisoner details' do
    context 'with missing prisoner details' do
      before do
        post :create, prisoner_step: { first_name: 'Oscar' }
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
        post :create, prisoner_step: prisoner_details
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
          visitors_step: { first_name: 'Ada' }
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
          to have_attributes(first_name: 'Ada')
      end
    end

    context 'with complete visitor details' do
      before do
        post :create,
          prisoner_step: prisoner_details,
          visitors_step: visitors_details
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
          to have_attributes(first_name: 'Ada')
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
          slots_step: slots_details
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
          to have_attributes(first_name: 'Ada')
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
          slots_step: { option_0: '' }
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
          to have_attributes(first_name: 'Ada')
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
        confirmation_step: confirmation_details
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
            first_name: 'Ada',
            last_name: 'Lovelace',
            date_of_birth: Date.new(1970, 11, 30),
            email_address: 'ada@test.example.com',
            phone_no: '01154960222'
          ),
          an_object_having_attributes(
            option_0: '2015-01-02T09:00/10:00',
            option_1: '2015-01-03T09:00/10:00',
            option_2: '2015-01-04T09:00/10:00'
          )
        )
      post :create, params
    end
  end
end
