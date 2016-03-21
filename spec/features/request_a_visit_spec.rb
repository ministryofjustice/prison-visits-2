require 'rails_helper'

RSpec.feature 'Booking a visit', js: true do
  include ActiveJobHelper
  include FeaturesHelper

  let!(:prison) { create(:prison, name: 'Reading Gaol') }

  # Whitespace on email to test stripping
  let(:visitor_email) { ' ado@test.example.com ' }

  scenario 'happy path' do
    visit booking_requests_path(locale: 'en')

    enter_prisoner_information \
      prison_name: 'Reading Gaol', first_name: 'Oscar', last_name: 'Wilde'
    click_button 'Continue'

    enter_visitor_information email_address: visitor_email
    select '1', from: 'How many other visitors?'
    enter_visitor_information index: 1
    click_button 'Continue'

    select_slots
    find_button('Continue').trigger('click')

    expect(page).to have_text('Check your request')

    click_button 'Send request'

    expect(page).to have_text('Your request is being processed')

    expect(prison.email_address).
      to receive_email.
      with_subject(/\AVisit request for Oscar Wilde on \w+ \d+ \w+\z/).
      and_body(/Prisoner:\s*Oscar Wilde/)
    expect(visitor_email.strip).
      to receive_email.
      with_subject(/we’ve received your visit request for \w+ \d+ \w+\z/).
      and_body(/Prisoner:\s*Oscar W/)

    visit = Visit.last
    expect(visit.visitors.length).to eq(2)
  end

  scenario 'validation errors' do
    visit booking_requests_path(locale: 'en')
    click_button 'Continue'
    expect(page).to have_text('Prisoner first name is required')

    enter_prisoner_information prison_name: 'Reading Gaol'
    click_button 'Continue'

    enter_visitor_information date_of_birth: Date.new(2014, 11, 30)
    click_button 'Continue'

    expect(page).to have_text('There must be at least one adult visitor')
  end

  scenario 'review and edit' do
    visit booking_requests_path(locale: 'en')

    enter_prisoner_information
    click_button 'Continue'

    enter_visitor_information
    click_button 'Continue'

    select_slots 1
    click_button 'Continue'

    expect(page).to have_text('Check your request')

    click_button 'Change prisoner details'

    fill_in 'Prisoner last name', with: 'Featherstone-Haugh'
    click_button 'Continue'

    expect(page).to have_text('Check your request')
    expect(page).to have_text('Featherstone-Haugh')

    click_button 'Change visitor details'

    fill_in 'Your last name', with: 'Colquhoun'
    click_button 'Continue'

    expect(page).to have_text('Check your request')
    expect(page).to have_text('Colquhoun')

    click_button 'Change visit details'

    select_nth_slot 2
    click_button 'Continue'

    expect(page).to have_text('Check your request')
    expect(page).to have_text('First choice')
    expect(page).to have_text('Alternatives')

    click_button 'Send request'

    expect(page).to have_text('Your request is being processed')
  end
end
