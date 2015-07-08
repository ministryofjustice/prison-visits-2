require 'simplecov'
require 'simplecov-rcov'
SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter
SimpleCov.start 'rails' do
  add_filter '/gem/'
end
SimpleCov.minimum_coverage 100

# Minimal auto-load for quicker specs. This avoids loading the whole of Rails
# solely for dependency resolution.
autoload :ActiveModel, 'active_model'
autoload :Virtus, 'virtus'
require 'active_support/dependencies'
Dir[File.expand_path('../../{lib,app/**/*}', __FILE__)].each do |path|
  next unless File.directory?(path)
  ActiveSupport::Dependencies.autoload_paths << path
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
  end

  config.profile_examples = 10

  config.order = :random
  Kernel.srand config.seed
end
