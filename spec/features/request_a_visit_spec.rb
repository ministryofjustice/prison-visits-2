require 'rails_helper'

RSpec.feature 'Booking a visit', js: true do
  include ActiveJobHelper

  let!(:prison) { create(:prison, name: 'Reading Gaol') }

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

    click_button 'Continue'

    available_slots = all('#slots_step_option_0 option').map(&:text)
    select available_slots[1], from: 'Option 1'
    select available_slots[2], from: 'Option 1'
    select available_slots[3], from: 'Option 1'

    click_button 'Continue'

    expect(page).to have_text('Check your request')

    click_button 'Send request'

    expect(page).to have_text('Your request is being processed')

    expect(prison.email_address).
      to receive_email.
      with_subject(/\AVisit request for Oscar Wilde on \w+ \d+ \w+\z/).
      and_body(/Prisoner:\s*Oscar Wilde/)
  end

  scenario 'validation errors' do
    visit steps_path
    click_button 'Continue'
    expect(page).to have_text('Prisoner first name is required')
  end
end
