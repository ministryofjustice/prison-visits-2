require 'simplecov'
require 'simplecov-rcov'
SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
SimpleCov.minimum_coverage 100

# Minimal auto-load for quicker specs. This avoids loading the whole of Rails
# solely for dependency resolution.
autoload :ActiveModel, 'active_model'
autoload :Virtus, 'virtus'
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

Dir[File.expand_path("../support/matchers/*.rb", __FILE__)].each do |path|
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

VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!

  config.ignore_request do |request|
    # Ignore capybara requests within feature tests
    request.uri =~ /__identify__/
  end
end
