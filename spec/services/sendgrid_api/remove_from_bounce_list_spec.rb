require 'rails_helper'
require_relative '../sendgrid_api_shared_context'
require_relative './shared_examples'

RSpec.describe SendgridApi, '.remove_from_bounce_list' do
  subject {
    described_class.remove_from_bounce_list('test@example.com')
  }

  context 'sendgrid credentials are set' do
    include_examples 'error handling'
    include_examples 'timeout handling'

    context 'when there is no bounce' do
      include_examples 'API reports email does not exist'
    end

    context 'when there is a bounce' do
      describe 'it removes it' do
        include_examples 'API reports success'
      end
    end

    include_examples 'error handling for missing credentials'
  end
end
