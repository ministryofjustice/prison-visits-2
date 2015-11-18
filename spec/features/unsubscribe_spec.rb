require 'rails_helper'

RSpec.feature 'Booking a visit', js: true do
  include ActiveJobHelper

  scenario 'happy path' do
    visit unsubscribe_path
    expect(page).to have_text('Why did I receive this email?')
    expect(page).to have_text('because you requested a prison visit.')
  end
end
