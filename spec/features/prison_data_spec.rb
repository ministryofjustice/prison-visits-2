require 'rails_helper'

RSpec.feature 'Prison seed data' do
  scenario 'Importing all current prisons' do
    PrisonSeeder.seed! Rails.root.join('db', 'seeds')
  end
end
