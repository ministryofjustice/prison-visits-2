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
      option_1: '2015-01-02T09:00/10:00',
      option_2: '2015-01-03T09:00/10:00',
      option_3: '2015-01-04T09:00/10:00'
    }
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
    allow(Prison).to receive(:find).with(1).and_return(prison)
  end

  context 'on the first prisoner details page' do
    before do
      get :index
    end

    it 'assigns a new PrisonerStep' do
      expect(assigns(:prisoner_step)).to be_a(PrisonerStep)
    end

    it 'renders the prisoner template' do
      expect(response).to render_template('prisoner')
    end
  end

  context 'after submitting prisoner details' do
    context 'with missing prisoner details' do
      before do
        post :create, prisoner_step: { first_name: 'Oscar' }
      end

      it 'renders the prisoner template' do
        expect(response).to render_template('prisoner')
      end

      it 'assigns a PrisonerStep' do
        expect(assigns(:prisoner_step)).to be_a(PrisonerStep)
      end

      it 'initialises the PrisonerStep with the supplied attributes' do
        expect(assigns(:prisoner_step)).
          to have_attributes(first_name: 'Oscar')
      end
    end

    context 'with complete prisoner details' do
      before do
        post :create, prisoner_step: prisoner_details
      end

      it 'renders the visitors template' do
        expect(response).to render_template('visitors')
      end

      it 'assigns a PrisonerStep' do
        expect(assigns(:prisoner_step)).to be_a(PrisonerStep)
      end

      it 'initialises the PrisonerStep with the supplied attributes' do
        expect(assigns(:prisoner_step)).
          to have_attributes(first_name: 'Oscar')
      end

      it 'assigns a new VisitorsStep' do
        expect(assigns(:visitors_step)).to be_a(VisitorsStep)
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
        expect(response).to render_template('visitors')
      end

      it 'assigns a PrisonerStep' do
        expect(assigns(:prisoner_step)).to be_a(PrisonerStep)
      end

      it 'initialises the PrisonerStep with the supplied attributes' do
        expect(assigns(:prisoner_step)).
          to have_attributes(first_name: 'Oscar')
      end

      it 'assigns a VisitorsStep' do
        expect(assigns(:visitors_step)).to be_a(VisitorsStep)
      end

      it 'initialises the VisitorsStep with the supplied attributes' do
        expect(assigns(:visitors_step)).
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
        expect(response).to render_template('slots')
      end

      it 'assigns a PrisonerStep' do
        expect(assigns(:prisoner_step)).to be_a(PrisonerStep)
      end

      it 'initialises the PrisonerStep with the supplied attributes' do
        expect(assigns(:prisoner_step)).
          to have_attributes(first_name: 'Oscar')
      end

      it 'assigns a VisitorsStep' do
        expect(assigns(:visitors_step)).to be_a(VisitorsStep)
      end

      it 'initialises the VisitorsStep with the supplied attributes' do
        expect(assigns(:visitors_step)).
          to have_attributes(first_name: 'Ada')
      end

      it 'assigns a slots step' do
        expect(assigns(:slots_step)).to be_a(SlotsStep)
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
        expect(response).to render_template('confirmation')
      end

      it 'assigns a PrisonerStep' do
        expect(assigns(:prisoner_step)).to be_a(PrisonerStep)
      end

      it 'initialises the PrisonerStep with the supplied attributes' do
        expect(assigns(:prisoner_step)).
          to have_attributes(first_name: 'Oscar')
      end

      it 'assigns a VisitorsStep' do
        expect(assigns(:visitors_step)).to be_a(VisitorsStep)
      end

      it 'initialises the VisitorsStep with the supplied attributes' do
        expect(assigns(:visitors_step)).
          to have_attributes(first_name: 'Ada')
      end

      it 'assigns a slots step' do
        expect(assigns(:slots_step)).to be_a(SlotsStep)
      end

      it 'initialises the SlotsStep with the supplied attributes' do
        expect(assigns(:slots_step)).
          to have_attributes(option_1: '2015-01-02T09:00/10:00')
      end
    end
  end

  context 'after confirming' do
  end
end
