require 'poltergeist_helper'
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
      visit booking_requests_path(locale: 'en')
      enter_prisoner_information
      click_button 'Continue'
      enter_visitor_information email_address: expected_email_address
      click_button 'Continue'

      expect(page).to have_text('marked as spam')
      check 'Tick this box to confirm you’d like us to try sending messages to you again'
      click_button 'Continue'

      expect(page).to have_text('When do you want to visit?')
      select_slots
      # Something in the DOM appears to be intermittently confusing poltergeist
      # about this particular button. Sometimes, it does not find it when used
      # with 'click_button' This is their suggested workaround.
      find_button('Continue').trigger('click')

      expect(page).to have_text('Check your request')

      expect_any_instance_of(SendgridApi).to receive(:remove_from_spam_list).
        with(expected_email_address).
        and_return(irrelevant_response)

      expect_any_instance_of(SendgridApi).
        to_not receive(:remove_from_bounce_list)

      click_button 'Send request'

      expect(page).to have_text('Your request is being processed')
    end
  end

  context 'bounced' do
    include_context 'sendgrid reports a bounce'

    scenario 'overriding bounce' do
      visit booking_requests_path(locale: 'en')
      enter_prisoner_information
      click_button 'Continue'
      enter_visitor_information email_address: expected_email_address
      click_button 'Continue'

      expect(page).to have_text('returned in the past')
      check 'Tick this box to confirm you’d like us to try sending messages to you again'
      click_button 'Continue'

      expect(page).to have_text('When do you want to visit?')
      select_slots
      # Something in the DOM appears to be intermittently confusing poltergeist
      # about this particular button. Sometimes, it does not find it when used
      # with 'click_button' This is their suggested workaround.
      find_button('Continue').trigger('click')

      expect(page).to have_text('Check your request')

      expect_any_instance_of(SendgridApi).to receive(:remove_from_bounce_list).
        with(expected_email_address).
        and_return(irrelevant_response)

      expect_any_instance_of(SendgridApi).
        to_not receive(:remove_from_spam_list)

      click_button 'Send request'

      expect(page).to have_text('Your request is being processed')
    end
  end

  scenario 'when no overrides are present' do
    visit booking_requests_path(locale: 'en')
    enter_prisoner_information
    click_button 'Continue'
    enter_visitor_information email_address: expected_email_address
    click_button 'Continue'

    expect(page).to have_text('When do you want to visit?')
    select_slots
    # Something in the DOM appears to be intermittently confusing poltergeist
    # about this particular button. Sometimes, it does not find it when used
    # with 'click_button' This is their suggested workaround.
    find_button('Continue').trigger('click')

    expect(page).to have_text('Check your request')

    expect_any_instance_of(SendgridApi).
      to_not receive(:remove_from_bounce_list)
    expect_any_instance_of(SendgridApi).
      to_not receive(:remove_from_spam_list)

    click_button 'Send request'

    expect(page).to have_text('Your request is being processed')
  end
end
