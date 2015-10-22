require 'rails_helper'

RSpec.feature 'Booking a visit' do
  scenario 'happy path' do
    visit new_prisoner_step_path
  end
end
