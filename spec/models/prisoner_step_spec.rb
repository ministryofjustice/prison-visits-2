require 'rails_helper'

RSpec.describe PrisonerStep do
  subject { described_class.new(prison:) }

  let(:params) {
    {
      first_name: 'Joe',
      last_name: 'Bloggs',
      date_of_birth: {
        day: '31',
        month: '12',
        year: '1970'
      },
      number: 'a1234bc',
      prison_id: 'uuid'
    }
  }

  it 'does not fail if the date is invalid (anti-regression)' do
    params[:date_of_birth][:month] = '13'
    prisoner_step = described_class.new(params)

    dob = prisoner_step.date_of_birth

    expect(dob).to be_kind_of(AccessibleDate)
    expect(dob.month).to be(13)
  end

  it 'does not fail if the prisoner number has extra spaces' do
    params[:number] = 'a1234bc '

    prisoner_step = described_class.new(params)

    expect(prisoner_step).to be_valid
  end
end
