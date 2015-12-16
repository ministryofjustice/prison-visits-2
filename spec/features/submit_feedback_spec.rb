require 'rails_helper'

RSpec.feature 'Submit feedback', js: true do
  include ActiveJobHelper
  include FeaturesHelper

  scenario 'submitting feedback' do
    text = 'How many times did the Batmobile catch a flat?'
    email_address = 'user@test.example.com'

    visit booking_requests_path
    click_link 'Contact us'

    fill_in 'Your question', with: text
    fill_in 'Your email address', with: email_address

    expect(ZendeskTicketsJob).to receive(:perform_later) do |fb|
      expect(fb.body).to eq(text)
      expect(fb.email_address).to eq(email_address)
      expect(fb.user_agent).to match('Mozilla')
      expect(fb.referrer).to match(booking_requests_path)
    end

    click_button 'Send'

    expect(page).to have_text('Thank you for your feedback')
  end
end
