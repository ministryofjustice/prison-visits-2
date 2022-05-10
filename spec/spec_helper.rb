require 'simplecov'
require 'webmock'

include WebMock::API

WebMock.enable!

SimpleCov.minimum_coverage 95

if ENV['CIRCLE_ARTIFACTS']
  dir = File.join(ENV['CIRCLE_ARTIFACTS'], "coverage")
  SimpleCov.coverage_dir(dir)
end

# Minimal auto-load for quicker specs. This avoids loading the whole of Rails
# solely for dependency resolution.
autoload :ActiveModel, 'active_model'
require 'active_support/dependencies'

locations = %w[
  ../../lib/**/*
  ../../app/**/*
  ../support/helpers
]

locations.each do |location|
  Dir[File.expand_path(location, __FILE__)].each do |path|
    next unless File.directory?(path)

    ActiveSupport::Dependencies.autoload_paths << path
  end
end

Dir[File.expand_path('support/matchers/*.rb', __dir__)].sort.each do |path|
  require path
end

Dir[File.expand_path('support/shared/*.rb', __dir__)].sort.each do |path|
  require path
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  config.example_status_persistence_file_path = "spec/examples.txt"

  config.disable_monkey_patching!

  if config.files_to_run.one?
    config.default_formatter = 'doc'
  else
    SimpleCov.start 'rails' do
      add_filter '/gems/'
    end
  end

  config.profile_examples = 10

  config.order = :random
  Kernel.srand config.seed
end

require 'vcr'

# set VCR=1 when you wish to record new interactions with T3
vcr_mode = ENV.fetch('VCR', '0').to_i.freeze

VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  if vcr_mode.zero?
    config.hook_into :webmock
  else
    config.hook_into :faraday
  end
  config.configure_rspec_metadata!
  # config.allow_http_connections_when_no_cassette = true
  config.default_cassette_options = {
    # by default, all T3 interactions are already recorded
    record: vcr_mode.zero? ? :none : :new_episodes,
  }
  config.ignore_request do |request|
    # Ignore capybara requests within feature tests
    request.uri =~ /__identify__|session|oauth/
  end
  config.filter_sensitive_data('authorisation_header') do |interaction|
    interaction.request.headers['Authorization']&.first
  end
end
