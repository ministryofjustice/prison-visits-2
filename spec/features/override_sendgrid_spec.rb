require 'rails_helper'
require 'shared_sendgrid_context'

RSpec.feature "overriding Sendgrid", js: true do
  include ActiveJobHelper
  include FeaturesHelper

  let(:expected_email_address) { 'test@maildrop.dsd.io' }
  let(:irrelevant_response) { { 'message' => 'success' } }
  let!(:prison) { create(:prison, name: 'Reading Gaol') }

  before do
    ActionMailer::Base.deliveries.clear
  end

  context 'spam' do
    include_context 'sendgrid reports spam'

    scenario 'overriding spam report' do
      visit booking_requests_path
      enter_prisoner_information
      click_button 'Continue'
      enter_visitor_information email_address: expected_email_address
      click_button 'Continue'

      expect(page).to have_text('marked as spam')
      check 'Tick this box to confirm you’d like us to try sending messages to you again'
      click_button 'Continue'

      expect(page).to have_content('When do you want to visit?')
      select_slots
      click_button 'Continue'

      expect(page).to have_content('Check your request')

      expect(SendgridApi).to receive(:remove_from_spam_list).
        with(expected_email_address).
        and_return(irrelevant_response)

      expect(SendgridApi).to_not receive(:remove_from_bounce_list)

      click_button 'Send request'

      expect(page).to have_content('Your request is being processed')
    end
  end

  context 'bounced' do
    include_context 'sendgrid reports a bounce'

    scenario 'overriding bounce' do
      visit booking_requests_path
      enter_prisoner_information
      click_button 'Continue'
      enter_visitor_information email_address: expected_email_address
      click_button 'Continue'

      expect(page).to have_text('returned in the past')
      check 'Tick this box to confirm you’d like us to try sending messages to you again'
      click_button 'Continue'

      expect(page).to have_content('When do you want to visit?')
      select_slots
      click_button 'Continue'

      expect(page).to have_content('Check your request')

      expect(SendgridApi).to receive(:remove_from_bounce_list).
        with(expected_email_address).
        and_return(irrelevant_response)

      expect(SendgridApi).to_not receive(:remove_from_spam_list)

      click_button 'Send request'

      expect(page).to have_content('Your request is being processed')
    end
  end

  scenario 'when no overrides are present' do
    visit booking_requests_path
    enter_prisoner_information
    click_button 'Continue'
    enter_visitor_information email_address: expected_email_address
    click_button 'Continue'

    expect(page).to have_content('When do you want to visit?')
    select_slots
    click_button 'Continue'

    expect(page).to have_content('Check your request')

    expect(SendgridApi).to_not receive(:remove_from_bounce_list)
    expect(SendgridApi).to_not receive(:remove_from_spam_list)

    click_button 'Send request'

    expect(page).to have_content('Your request is being processed')
  end
end
