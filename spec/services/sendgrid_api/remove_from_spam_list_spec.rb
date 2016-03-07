require 'rails_helper'
require_relative '../sendgrid_api_shared_context'
require_relative './shared_examples'

RSpec.describe SendgridApi, '#remove_from_spam_list' do
  let(:instance) { described_class.new }
  subject {
    instance.remove_from_spam_list('test@example.com')
  }

  include_context 'sendgrid shared tools'

  context 'sendgrid credentials are set' do
    include_examples 'error handling'
    include_examples 'there is a timeout'
    include_examples 'sendgrid pool timeouts'

    context 'when email does not exist' do
      include_examples 'API reports email does not exist'
    end

    context 'when email exists' do
      include_examples 'API reports success'
    end
  end

  include_examples 'error handling for missing credentials'
end
