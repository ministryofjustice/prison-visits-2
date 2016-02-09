require 'rails_helper'

RSpec.describe BookingRequestCreator do
  let(:prisoner_step) {
    PrisonerStep.new(
      prison_id: 'PRISONID',
      first_name: 'Oscar',
      last_name: 'Wilde',
      date_of_birth: Date.new(1980, 12, 31),
      number: 'a1234bc'
    )
  }

  let(:visitors_step) {
    VisitorsStep.new(
      email_address: 'ada@test.example.com',
      phone_no: '01154960222',
      visitors: [
        {
          first_name: 'Ada',
          last_name: 'Lovelace',
          date_of_birth: Date.new(1970, 11, 30)
        },
        {
          first_name: 'Charlie',
          last_name: 'Chaplin',
          date_of_birth: Date.new(2005, 1, 2)
        }
      ]
    )
  }

  let(:slots_step) {
    SlotsStep.new(
      option_0: '2015-01-02T09:00/10:00',
      option_1: '2015-01-03T09:00/10:00',
      option_2: '2015-01-04T09:00/10:00'
    )
  }

  let(:mailing) {
    double(Mail::Message, deliver_later: nil)
  }

  before do
    allow(PrisonMailer).to receive(:request_received).and_return(mailing)
    allow(VisitorMailer).to receive(:request_acknowledged).and_return(mailing)
  end

  context 'creating records' do
    let(:visitors) { double }

    before do
      allow(Prisoner).to receive(:create!).
        and_return instance_double(Prisoner, id: 'PRISONERID')
      allow(Visit).to receive(:create!).
        and_return instance_double(Visit, id: 2, visitors: visitors)
      allow(visitors).to receive(:create!)
      allow(visitors).to receive(:create!)
    end

    it 'creates a Visit record with the specified locale' do
      expect(Visit).
        to receive(:create!).
        with(
          prison_id: 'PRISONID',
          prisoner_id: 'PRISONERID',
          contact_email_address: 'ada@test.example.com',
          contact_phone_no: '01154960222',
          override_delivery_error: nil,
          delivery_error_type: nil,
          slot_option_0: '2015-01-02T09:00/10:00',
          slot_option_1: '2015-01-03T09:00/10:00',
          slot_option_2: '2015-01-04T09:00/10:00',
          locale: :cy
        ).and_return instance_double(Visit, id: 2, visitors: visitors)
      subject.create! prisoner_step, visitors_step, slots_step, :cy
    end

    it 'creates a Visitor record' do
      expect(visitors).
        to receive(:create!).
        with(
          first_name: 'Ada',
          last_name: 'Lovelace',
          date_of_birth: Date.new(1970, 11, 30),
          sort_index: 0
        )
      subject.create! prisoner_step, visitors_step, slots_step, :en
    end

    it 'creates a Prisoner record' do
      expect(Prisoner).
        to receive(:create!).
        with(
          first_name: 'Oscar',
          last_name: 'Wilde',
          date_of_birth: Date.new(1980, 12, 31),
          number: 'a1234bc'
        ).and_return instance_double(Prisoner, id: 'PRISONERID')
      subject.create! prisoner_step, visitors_step, slots_step, :en
    end
  end

  context 'emailing and logging' do
    let(:visit) { instance_double(Visit, id: 2, visitors: double(create!: nil)) }

    before do
      allow(Visit).to receive(:create!).and_return(visit)
    end

    it 'emails the prison' do
      expect(PrisonMailer).to receive(:request_received).with(visit).
        and_return(mailing)
      expect(mailing).to receive(:deliver_later)
      subject.create! prisoner_step, visitors_step, slots_step, :en
    end
  end
end
