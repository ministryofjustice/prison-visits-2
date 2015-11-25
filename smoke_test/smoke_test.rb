require 'capybara'
require 'capybara/dsl'
require 'phantomjs/poltergeist'
require 'capybara/poltergeist'

require_relative 'state'
require_relative 'mail_box'
require_relative 'steps/base_step'
require_relative 'steps/prisoner_page'
require_relative 'steps/visitors_page'
require_relative 'steps/slots_page'
require_relative 'steps/check_your_request_page'
require_relative 'steps/visitor_booking_receipt'
require_relative 'steps/prison_booking_request'
require_relative 'steps/process_visit_request_page'
require_relative 'steps/visitor_booking_confirmation'
require_relative 'steps/prison_booking_confirmation_copy'
require_relative 'steps/cancel_booking_page'
require_relative 'steps/prison_booking_cancelled'

module SuppressJsConsoleLogging; end
Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new \
    app, phantomjs_logger: SuppressJsConsoleLogging
end

Capybara.run_server = false
Capybara.current_driver = :poltergeist
Capybara.app_host = ENV.fetch('SMOKE_TEST_APP_HOST', 'http://localhost:3000')

module SmokeTest
  SMOKE_TEST_EMAIL_LOCAL_PART = ENV.fetch(
    'SMOKE_TEST_EMAIL_LOCAL_PART',
    'smoke-test')
  SMOKE_TEST_EMAIL_DOMAIN = ENV.fetch('SMOKE_TEST_EMAIL_DOMAIN', 'example.com')
  SMOKE_TEST_EMAIL_PASSWORD = ENV.fetch('SMOKE_TEST_EMAIL_PASSWORD', nil)
  SMOKE_TEST_EMAIL_HOST = ENV.fetch('SMOKE_TEST_EMAIL_HOST', nil)

  STEPS = [
    Steps::PrisonerPage,
    Steps::VisitorsPage,
    Steps::SlotsPage,
    Steps::CheckYourRequestPage,
    Steps::VisitorBookingReceipt,
    Steps::PrisonBookingRequest,
    Steps::ProcessVisitRequestPage,
    Steps::PrisonBookingConfirmationCopy,
    Steps::VisitorBookingConfirmation,
    Steps::CancelBookingPage,
    Steps::PrisonBookingCancelled
  ]

  class Runner
    include Capybara::DSL

    def run
      puts 'Beginning Smoke Test..'
      Capybara.reset_sessions!
      visit '/request'
      STEPS.map(&method(:complete))
      puts 'Smoke Test Completed'
    end

  private

    def complete(step)
      current_step = step.new state
      current_step.validate!
      current_step.complete_step
    end

    def state
      @state ||= State.new
    end
  end
end

SmokeTest::Runner.new.run
