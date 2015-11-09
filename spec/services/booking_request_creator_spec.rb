require 'rails_helper'

RSpec.describe BookingRequestCreator do
  let(:prisoner_step) {
    PrisonerStep.new(
      prison_id: 1,
      first_name: 'Oscar',
      last_name: 'Wilde',
      date_of_birth: Date.new(1980, 12, 31),
      number: 'a1234bc'
    )
  }
    
  let(:visitors_step) {
    VisitorsStep.new(
      first_name: 'Ada',
      last_name: 'Lovelace',
      date_of_birth: Date.new(1970, 11, 30),
      email_address: 'ada@test.example.com',
      phone_no: '01154960222'
    )
  }
    
  let(:slots_step) {
    SlotsStep.new(
      option_1: '2015-01-02T09:00/10:00',
      option_2: '2015-01-03T09:00/10:00',
      option_3: '2015-01-04T09:00/10:00'
    )
  }

  it 'creates a Visit record' do
    expect(Visit).
      to receive(:create!).
      with(
        prison_id: 1,
        prisoner_first_name: 'Oscar',
        prisoner_last_name: 'Wilde',
        prisoner_date_of_birth: Date.new(1980, 12, 31),
        prisoner_number: 'a1234bc',
        visitor_first_name: 'Ada',
        visitor_last_name: 'Lovelace',
        visitor_date_of_birth: Date.new(1970, 11, 30),
        visitor_email_address: 'ada@test.example.com',
        visitor_phone_no: '01154960222',
        slot_option_1: '2015-01-02T09:00/10:00',
        slot_option_2: '2015-01-03T09:00/10:00',
        slot_option_3: '2015-01-04T09:00/10:00'
      )

    described_class.new.create! prisoner_step, visitors_step, slots_step
  end
end
