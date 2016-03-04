require 'rails_helper'
require_relative '../sendgrid_api_shared_context'
require_relative './shared_examples'

RSpec.describe SendgridApi, '#spam_reported?' do
  let(:instance) { described_class.new }
  subject {
    instance.spam_reported?('test@example.com')
  }

  include_context 'sendgrid shared tools'

  context 'sendgrid credentials are set' do
    include_examples 'error handling'

    context 'when there is no spam report' do
      it_should_behave_like 'there is nothing to report'
    end

    context 'when there is a spam report' do
      let(:body) {
        [{
          ip: '174.36.80.219',
          email: 'test@example.com',
          created: '2009-12-06 15:45:08'
        }].to_json
      }

      it_should_behave_like 'there is something to report'
    end
  end

  include_examples 'error handling for missing credentials'
end
