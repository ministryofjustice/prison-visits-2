require 'rails_helper'
require_relative '../sendgrid_api_shared_context'
require_relative './shared_examples'

RSpec.describe SendgridApi, '#spam_reported?' do
  include_context 'sendgrid instance'

  subject {
    instance.spam_reported?('test@example.com')
  }

  include_context 'sendgrid shared tools'

  context 'sendgrid credentials are set' do
    include_examples 'error handling'
    include_examples 'there is a timeout'
    include_examples 'sendgrid pool timeouts'

    context 'when there is no spam report' do
      it_behaves_like 'there is nothing to report'
    end

    context 'when there is a spam report' do
      let(:body) {
        [{
          ip: '174.36.80.219',
          email: 'test@example.com',
          created: '2009-12-06 15:45:08'
        }].to_json
      }

      it_behaves_like 'there is something to report'
    end
  end

  include_examples 'error handling for missing credentials'
end
