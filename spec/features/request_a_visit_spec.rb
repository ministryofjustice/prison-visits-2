require 'rails_helper'

RSpec.feature 'Booking a visit', js: true do
  before :all do
    Prison.create!(
      name: 'Reading Gaol',
      nomis_id: 'XYZ',
      enabled: true,
      address: '1 High Street',
      email_address: 'reading.gaol@test.example.com',
      phone_no: '01154960123',
      slot_details: {
        'recurring' => {
          'mon' => ['1400-1610'],
          'tue' => ['0900-1000', '1400-1610']
        }
      }
    )
  end

  scenario 'happy path' do
    visit steps_path

    fill_in 'Prisoner first name', with: 'Oscar'
    fill_in 'Prisoner last name', with: 'Wilde'
    fill_in 'Day', with: '31'
    fill_in 'Month', with: '12'
    fill_in 'Year', with: '1980'
    fill_in 'Prisoner number', with: 'a1234bc'
    select 'Reading Gaol', from: 'Name of the prison'

    click_button 'Continue'

    fill_in 'Your first name', with: 'Ada'
    fill_in 'Your last name', with: 'Lovelace'
    fill_in 'Day', with: '30'
    fill_in 'Month', with: '11'
    fill_in 'Year', with: '1970'
    fill_in 'Email address', with: 'ada@test.example.com'
    fill_in 'Phone number', with: '01154960222'
  end
end
