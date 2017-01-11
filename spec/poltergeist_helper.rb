# frozen_string_literal: true
require 'rails_helper'
require 'capybara/rspec'
require 'capybara/poltergeist'

Capybara.default_driver = :poltergeist
Capybara.javascript_driver = :poltergeist
Capybara.default_max_wait_time = 3
Capybara.asset_host = "http://localhost:3000"
