# frozen_string_literal: true
require 'rails_helper'

RSpec.feature 'Prison seed data' do
  scenario 'Importing all current prisons' do
    path = Rails.root.join('db', 'seeds')
    EstateSeeder.seed! path
    PrisonSeeder.seed! path
  end
end
