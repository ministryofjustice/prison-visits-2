require 'spec_helper'
require 'json'
require 'open3'
require 'rails'

RSpec.describe Rails::Application do
  def configuration_for(overrides)
    environment = {
      'RAILS_ENV' => 'test',
      'RACK_ENV' => 'test',
      'DB_POOL_SIZE' => nil,
      'HTTP_POOL_SIZE' => nil,
      'RAILS_MAX_THREADS' => nil,
      'DATABASE_URL' => 'postgresql://config_test:config_test@127.0.0.1:1/config_test'
    }.merge(overrides)
    script = 'puts JSON.generate(database_pool: ActiveRecord::Base.connection_db_config.pool, ' \
             'http_pool: Rails.configuration.connection_pool_size)'
    output, errors, result = Open3.capture3(
      environment, RbConfig.ruby, '-r', File.expand_path('../../config/environment', __dir__), '-e', script)

    expect(result.success?).to be(true), errors
    JSON.parse(output.lines.last)
  end

  [
    ['existing defaults', {}, 5, 5],
    ['legacy thread sizing', { 'RAILS_MAX_THREADS' => '7' }, 7, 7],
    ['database-only override', { 'DB_POOL_SIZE' => '1' }, 1, 5],
    ['HTTP-only override', { 'HTTP_POOL_SIZE' => '8' }, 5, 8],
    ['independent overrides', { 'DB_POOL_SIZE' => '3', 'HTTP_POOL_SIZE' => '8', 'RAILS_MAX_THREADS' => '7' }, 3, 8],
    ['database URL precedence',
     {
       'DB_POOL_SIZE' => '1',
       'DATABASE_URL' => 'postgresql://config_test:config_test@127.0.0.1:1/config_test?pool=9'
     },
     9,
     5],
    ['production database URL preserves the configured pool',
     {
       'RAILS_ENV' => 'production',
       'DB_POOL_SIZE' => '1',
       'DATABASE_URL' => 'postgresql://config_test:config_test@127.0.0.1:1/config_test',
       'STAFF_SERVICE_URL' => 'https://staff.example.test',
       'PUBLIC_SERVICE_URL' => 'https://public.example.test',
       'SMTP_DOMAIN' => 'example.test',
       'SECRET_KEY_BASE' => 'test-secret-key-base-for-isolated-production-boot'
     },
     1,
     5],
    ['production database URL pool retains precedence',
     {
       'RAILS_ENV' => 'production',
       'DB_POOL_SIZE' => '1',
       'DATABASE_URL' => 'postgresql://config_test:config_test@127.0.0.1:1/config_test?pool=9',
       'STAFF_SERVICE_URL' => 'https://staff.example.test',
       'PUBLIC_SERVICE_URL' => 'https://public.example.test',
       'SMTP_DOMAIN' => 'example.test',
       'SECRET_KEY_BASE' => 'test-secret-key-base-for-isolated-production-boot'
     },
     9,
     5]
  ].each do |description, overrides, database_pool, http_pool|
    it "preserves #{description}" do
      expect(configuration_for(overrides)).to eq(
        'database_pool' => database_pool, 'http_pool' => http_pool)
    end
  end
end
