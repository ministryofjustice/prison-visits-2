require 'rails_helper'

RSpec.describe StepsProcessor do
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
        0 => {
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
    allow(Prison).to receive(:find_by).with(id: 1).and_return(prison)
  end

  subject { described_class.new(HashWithIndifferentAccess.new(params)) }

  shared_examples 'it has all steps' do
    it 'has a PrisonerStep' do
      expect(subject.steps[:prisoner_step]).to be_a(PrisonerStep)
    end

    it 'has a VisitorsStep' do
      expect(subject.steps[:visitors_step]).to be_a(VisitorsStep)
    end

    it 'has a SlotsStep' do
      expect(subject.steps[:slots_step]).to be_a(SlotsStep)
    end
  end

  shared_examples 'it is incomplete' do
    it 'does not tell BookingRequestCreator to create a Visit record' do
      allow(BookingRequestCreator).to receive(:new).never
      subject.execute!
    end
  end

  context 'with no params' do
    let(:params) { {} }

    it 'chooses the prisoner_step template' do
      expect(subject.template_name).to eq(:prisoner_step)
    end

    it_behaves_like 'it has all steps'
    it_behaves_like 'it is incomplete'
  end

  context 'with incomplete prisoner details' do
    let(:params) { { prisoner_step: { first_name: 'Oscar' } } }

    it 'chooses the prisoner_step template' do
      expect(subject.template_name).to eq(:prisoner_step)
    end

    it 'returns a PrisonerStep with the supplied attributes' do
      expect(subject.steps[:prisoner_step]).
        to have_attributes(first_name: 'Oscar')
    end

    it_behaves_like 'it has all steps'
    it_behaves_like 'it is incomplete'
  end

  context 'with complete prisoner details' do
    let(:params) { { prisoner_step: prisoner_details } }

    it 'chooses the visitors_step template' do
      expect(subject.template_name).to eq(:visitors_step)
    end

    it 'initialises the PrisonerStep with the supplied attributes' do
      expect(subject.steps[:prisoner_step]).
        to have_attributes(first_name: 'Oscar')
    end

    it_behaves_like 'it has all steps'
    it_behaves_like 'it is incomplete'

    context 'and the intention to go to the prisoner step' do
      let(:params) { super().merge(review_step: :prisoner_step) }

      it 'chooses the prisoner_step template' do
        expect(subject.template_name).to eq(:prisoner_step)
      end
    end
  end

  context 'with incomplete visitor details' do
    let(:params) {
      {
        prisoner_step: prisoner_details,
        visitors_step: { phone_no: '01154960222' }
      }
    }

    it 'chooses the visitors_step template' do
      expect(subject.template_name).to eq(:visitors_step)
    end

    it 'initialises the PrisonerStep with the supplied attributes' do
      expect(subject.steps[:prisoner_step]).
        to have_attributes(first_name: 'Oscar')
    end

    it 'initialises the VisitorsStep with the supplied attributes' do
      expect(subject.steps[:visitors_step]).
        to have_attributes(phone_no: '01154960222')
    end

    it_behaves_like 'it has all steps'
    it_behaves_like 'it is incomplete'
  end

  context 'with complete visitor details' do
    let(:params) {
      {
        prisoner_step: prisoner_details,
        visitors_step: visitors_details
      }
    }

    it 'chooses the slots_step template' do
      expect(subject.template_name).to eq(:slots_step)
    end

    it 'initialises the PrisonerStep with the supplied attributes' do
      expect(subject.steps[:prisoner_step]).
        to have_attributes(first_name: 'Oscar')
    end

    it 'initialises the VisitorsStep with the supplied attributes' do
      expect(subject.steps[:visitors_step]).
        to have_attributes(phone_no: '01154960222')
    end

    it_behaves_like 'it has all steps'
    it_behaves_like 'it is incomplete'

    context 'and the intention to go to the prisoner step' do
      let(:params) { super().merge(review_step: :prisoner_step) }

      it 'chooses the prisoner_step template' do
        expect(subject.template_name).to eq(:prisoner_step)
      end
    end
  end

  context 'with at least one slot' do
    let(:params) {
      {
        prisoner_step: prisoner_details,
        visitors_step: visitors_details,
        slots_step: slots_details
      }
    }

    it 'chooses the confirmation template' do
      expect(subject.template_name).to eq(:confirmation_step)
    end

    it 'initialises the PrisonerStep with the supplied attributes' do
      expect(subject.steps[:prisoner_step]).
        to have_attributes(first_name: 'Oscar')
    end

    it 'initialises the VisitorsStep with the supplied attributes' do
      expect(subject.steps[:visitors_step]).
        to have_attributes(phone_no: '01154960222')
    end

    it 'initialises the SlotsStep with the supplied attributes' do
      expect(subject.steps[:slots_step]).
        to have_attributes(option_0: '2015-01-02T09:00/10:00')
    end

    it_behaves_like 'it has all steps'
    it_behaves_like 'it is incomplete'
  end

  context 'with no slots selected' do
    let(:params) {
      {
        prisoner_step: prisoner_details,
        visitors_step: visitors_details,
        slots_step: { option_0: '' }
      }
    }

    it 'chooses the slots_step template' do
      expect(subject.template_name).to eq(:slots_step)
    end

    it 'initialises the PrisonerStep with the supplied attributes' do
      expect(subject.steps[:prisoner_step]).
        to have_attributes(first_name: 'Oscar')
    end

    it 'initialises the VisitorsStep with the supplied attributes' do
      expect(subject.steps[:visitors_step]).
        to have_attributes(phone_no: '01154960222')
    end

    it_behaves_like 'it has all steps'
    it_behaves_like 'it is incomplete'
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

    it 'chooses the completed template' do
      expect(subject.template_name).to eq(:completed)
    end

    it 'tells BookingRequestCreator to create a Visit record' do
      allow(BookingRequestCreator).to receive(:new).
        and_return(booking_request_creator)
      allow(booking_request_creator).to receive(:create!)
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
          )
        )
      subject.execute!
    end
  end
end
