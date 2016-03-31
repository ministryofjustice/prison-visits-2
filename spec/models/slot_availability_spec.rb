require 'rails_helper'

RSpec.describe SlotAvailability, type: :model do
  subject { described_class.new(prison: prison) }

  let!(:prison) { create(:prison) }

  let(:default_prison_slots) {
    [
      "2016-04-11T14:00/16:10",
      "2016-04-12T09:00/10:00",
      "2016-04-12T14:00/16:10",
      "2016-04-18T14:00/16:10",
      "2016-04-19T09:00/10:00",
      "2016-04-19T14:00/16:10",
      "2016-04-25T14:00/16:10",
      "2016-04-26T09:00/10:00",
      "2016-04-26T14:00/16:10"
    ]
  }

  around do |example|
    travel_to Time.zone.local(2016, 3, 31) do
      example.run
    end
  end

  it 'fetches slot availability from the prison' do
    expect(subject.slots.map(&:iso8601)).to eq(default_prison_slots)
  end

  it 'can intersect available slots with prisoner availability' do
    offender = Nomis::Offender.new(id: 123)
    prisoner_availability = Nomis::PrisonerAvailability.new(
      dates: [Date.parse('2016-04-12'), Date.parse('2016-04-25')]
    )

    expect(Nomis::Api.instance).to receive(:lookup_active_offender).
      with(noms_id: 'a1234bc', date_of_birth: Date.parse('1970-01-01')).
      and_return(offender)
    expect(Nomis::Api.instance).to receive(:offender_visiting_availability).
      and_return(prisoner_availability)

    subject.restrict_by_prisoner(
      prisoner_number: 'a1234bc',
      prisoner_dob: Date.parse('1970-01-01')
    )

    expect(subject.slots.map(&:iso8601)).to eq(
      [
        '2016-04-12T09:00/10:00',
        '2016-04-12T14:00/16:10',
        '2016-04-25T14:00/16:10'
      ]
    )
  end
end
