require 'rails_helper'
require_relative '../sendgrid_api_shared_context'
require_relative './shared_examples'

RSpec.describe SendgridApi, '.remove_from_spam_list' do
  subject {
    described_class.remove_from_spam_list('test@example.com')
  }

  context 'sendgrid credentials are set' do
    include_examples 'error handling'

    context 'when email does not exist' do
      include_examples 'API reports email does not exist'
    end

    context 'when email exists' do
      include_examples 'API reports success'
    end

    include_examples 'error handling for missing credentials'
  end
end
