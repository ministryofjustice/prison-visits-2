require 'rails_helper'
require_relative '../sendgrid_api_shared_context'
require_relative './shared_examples'

RSpec.describe SendgridApi, '.bounced?' do
  subject {
    described_class.bounced?('test@example.com')
  }

  include_context 'sendgrid shared tools'

  context 'sendgrid credentials are set' do
    include_examples 'error handling'
    include_examples 'timeout handling'

    context 'when there is no bounce' do
      it_should_behave_like 'there is nothing to report'
    end

    context 'when there is a bounce' do
      let(:body) {
        [{ status: '4.0.4',
           created: '2011-09-16 22:02:19',
           reason: 'Unable to resolve MX host example.com',
           email: 'test@example.com' }].to_json
      }

      it_should_behave_like 'there is something to report'
    end
  end

  include_examples 'error handling for missing credentials'
end
