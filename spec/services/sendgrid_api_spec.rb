require 'rails_helper'

RSpec.describe SendgridApi do
  subject { described_class.new }

  context 'with sendgrid configured' do
    around do |example|
      smtp_settings = Rails.configuration.action_mailer.smtp_settings
      Rails.configuration.action_mailer.smtp_settings = {
        user_name: 'test_smtp_username',
        password: 'test_smtp_password'
      }
      example.run
      Rails.configuration.action_mailer.smtp_settings = smtp_settings
    end
  end

  context 'without sendgrid configured' do
    around do |example|
      smtp_settings = Rails.configuration.action_mailer.smtp_settings
      Rails.configuration.action_mailer.smtp_settings = {}
      example.run
      Rails.configuration.action_mailer.smtp_settings = smtp_settings
    end
  end
end
