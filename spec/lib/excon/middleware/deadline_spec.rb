require 'rails_helper'
require 'excon/middleware/deadline'

RSpec.describe Excon::Middleware::Deadline do
  let(:connection) do
    middlewares = Excon.defaults[:middlewares].unshift(described_class)
    Excon.new('http://127.0.0.1:9292', middlewares:)
  end

  let!(:deadline) { 2.seconds.from_now }

  subject(:response) do
    connection.request(method: :get,
                       path: '/foo',
                       deadline:)
  end

  it 'completes within the deadline' do
    WebMock.stub_request(:get, /\w/).to_return(status: 200)
    expect(response.status).to eq(200)
  end

  it 'does not complete within the deadline' do
    travel_to(deadline + 1.second) do
      expect { response }
        .to raise_error(Excon::Errors::DeadlineError, /Deadline/)
    end
  end

  it 'sets the read / write timeouts based one the deadline' do
    stack = double
    middleware = described_class.new(stack)

    travel_to(deadline - 1.second) do
      expect(stack).to receive(:request_call) do |datum|
        expect(datum[:read_timeout]).to be_present
        expect(datum[:write_timeout]).to be_present
      end

      middleware.request_call(deadline:)
    end
  end
end
