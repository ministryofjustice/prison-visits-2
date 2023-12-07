require 'rails_helper'

RSpec.describe BookingRequestCreator do
  let!(:prison) { FactoryBot.create(:prison) }
  let(:prisoner_step) {
    PrisonerStep.new(
      prison_id: prison.id,
      first_name: 'Oscar',
      last_name: 'Wilde',
      date_of_birth: Date.new(1980, 12, 31),
      number: 'a1234bc'
    )
  }

  let(:visitors_step) {
    VisitorsStep.new(
      email_address: 'ada@test.example.com',
      phone_no: '079 00112233',
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

  context 'when creating records' do
    it 'creates a Visit record with the specified locale and a human_id' do
      visit = subject.create!(prisoner_step, visitors_step, slots_step, :cy)
      expect(visit.locale).to eq('cy')
      expect(visit.human_id).not_to be_nil
    end

    it 'creates a Visitor record' do
      expect {
        subject.create!(prisoner_step, visitors_step, slots_step, :en)
      }.to change(Visitor, :count).by(2)
    end

    it 'creates a Prisoner record' do
      expect {
        subject.create!(prisoner_step, visitors_step, slots_step, :en)
      }.to change(Prisoner, :count).by(1)
    end
  end
end
