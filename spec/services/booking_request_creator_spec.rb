require 'rails_helper'

RSpec.describe BookingRequestCreator do
  let!(:prison) { FactoryGirl.create(:prison) }
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

  before do
    allow(PrisonMailer).to receive(:request_received).and_return(mailing)
    allow(VisitorMailer).to receive(:request_acknowledged).and_return(mailing)
  end

  context 'creating records' do
    it 'creates a Visit record with the specified locale' do
      visit = subject.create!(prisoner_step, visitors_step, slots_step, :cy)
      expect(visit.locale).to eq('cy')
    end

    it 'creates a Visitor record' do
      expect {
        subject.create!(prisoner_step, visitors_step, slots_step, :en)
      }.to change { Visitor.count }.by(2)
    end

    it 'creates a Prisoner record' do
      expect {
        subject.create!(prisoner_step, visitors_step, slots_step, :en)
      }.to change { Prisoner.count }.by(1)
    end
  end

  context 'emailing and logging' do
    let(:visit) { instance_double(Visit, id: 2, visitors: double(create!: nil)) }

    before do
      allow(Visit).to receive(:create!).and_return(visit)
    end

    it 'emails the prison' do
      expect(PrisonMailer).to receive(:request_received).with(instance_of(Visit)).
        and_return(mailing)
      expect(mailing).to receive(:deliver_later)
      subject.create!(prisoner_step, visitors_step, slots_step, :en)
    end
  end
end
