require 'rails_helper'
require_relative '../sendgrid_api_shared_context'
require_relative './shared_examples'

RSpec.describe SendgridApi, '#remove_from_bounce_list' do
  include_context 'with a sendgrid instance'

  subject {
    instance.remove_from_bounce_list('test@example.com')
  }

  include_context 'with sendgrid shared tools'

  context 'when sendgrid credentials are set' do
    include_examples 'error handling'
    include_examples 'there is a timeout'
    include_examples 'sendgrid pool timeouts'

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
