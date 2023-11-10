require 'rails_helper'
require 'excon/middleware/custom_idempotent'

# rubocop:disable RSpec/RepeatedDescription
RSpec.describe Excon::Middleware::CustomIdempotent do
  let(:connection) do
    middlewares = Excon.defaults[:middlewares].map { |middleware|
      if middleware == Excon::Middleware::Idempotent
        described_class
      else
        middleware
      end
    }

    Excon.new('http://127.0.0.1:9292', middlewares:)
  end

  let(:block_class) do
    Class.new do
      attr_reader :rewound

      def initialize
        @rewound = false
      end

      def call(_); end

      def rewind
        @rewound = true
      end
    end
  end

  it "Non-idempotent call with an erroring socket" do
    run_count = 0
    WebMock.stub_request(:get, /\w/).to_return(
      lambda do |_request|
        run_count += 1
        if run_count <= 3 # First 3 calls fail.
          raise Excon::Errors::SocketError, Exception.new("Mock Error")
        else
          { status: 200 }
        end
      end
    )

    expect { connection.request(method: :get, path: '/some-path') }
      .to raise_error(Excon::Errors::SocketError)
  end

  it "Idempotent request with a timeout error" do
    WebMock.stub_request(:get, /\w/).to_timeout

    expect { connection.request(method: :get, path: '/some-path') }
      .to raise_error(Excon::Errors::Timeout)
  end

  it "Idempotent request with socket erroring first 3 times" do
    run_count = 0
    WebMock.stub_request(:get, /\w/).to_return(
      lambda do |_request|
        run_count += 1
        if run_count <= 3 # First 3 calls fail.
          raise Excon::Errors::SocketError, Exception.new("Mock Error")
        else
          { status:  200 }
        end
      end
    )

    response = connection.request(method: :get, idempotent: true, path: '/some-path')
    expect(response.status).to eq(200)
  end

  it "Idempotent request with socket erroring first 5 times" do
    run_count = 0
    WebMock.stub_request(:get, /\w/).to_return(
      lambda do |_request|
        run_count += 1
        if run_count <= 5 # First 5 calls fail.
          raise Excon::Errors::SocketError, Exception.new("Mock Error")
        else
          { status: 200 }
        end
      end
    )

    expect { connection.request(method: :get, idempotent: true, path: '/some-path') }
      .to raise_error(Excon::Errors::SocketError)
  end

  it "Lowered retry limit with socket erroring first time" do
    run_count = 0
    WebMock.stub_request(:get, /\w/).to_return(
      lambda do |_request|
        run_count += 1
        if run_count <= 1 # First call fails.
          raise Excon::Errors::SocketError, Exception.new("Mock Error")
        else
          { status: 200 }
        end
      end
    )

    response = connection.request(method: :get, idempotent: true, path: '/some-path', retry_limit: 2)
    expect(response.status).to eq(200)
  end

  it "Lowered retry limit with socket erroring first 3 times" do
    run_count = 0
    WebMock.stub_request(:get, /\w/).to_return(
      lambda do |_request|
        run_count += 1
        if run_count <= 3 # First 3 calls fail.
          raise Excon::Errors::SocketError, Exception.new("Mock Error")
        else
          { status: 200 }
        end
      end
    )

    expect { connection.request(method: :get, idempotent: true, path: '/some-path', retry_limit: 2) }
      .to raise_error(Excon::Errors::SocketError)
  end

  it "Raised retry limit with socket erroring first 5 times" do
    run_count = 0
    WebMock.stub_request(:get, /\w/).to_return(
      lambda do |_request|
        run_count += 1
        if run_count <= 5 # First 5 calls fail.
          raise Excon::Errors::SocketError, Exception.new("Mock Error")
        else
          { status: 200 }
        end
      end
    )

    response = connection.request(method: :get, idempotent: true, path: '/some-path', retry_limit: 8)
    expect(response.status).to eq(200)
  end

  it "Raised retry limit with socket erroring first 9 times" do
    run_count = 0
    WebMock.stub_request(:get, /\w/).to_return(
      lambda do |_request|
        run_count += 1
        if run_count <= 9 # First 9 calls fail.
          raise Excon::Errors::SocketError, Exception.new("Mock Error")
        else
          { status: 200 }
        end
      end
    )

    expect { connection.request(method: :get, idempotent: true, path: '/some-path', retry_limit: 8) }
     .to raise_error(Excon::Errors::SocketError)
  end

  it "Retry limit in constructor with socket erroring first 5 times" do
    run_count = 0
    WebMock.stub_request(:get, /\w/).to_return(
      lambda do |_request|
        run_count += 1
        if run_count <= 5 # First 5 calls fail.
          raise Excon::Errors::SocketError, Exception.new("Mock Error")
        else
          { status: 200 }
        end
      end
    )

    response = connection.request(method: :get, idempotent: true, path: '/some-path', retry_limit: 6)
    expect(response.status).to eq(200)
  end

  it "Retry limit and sleep in constructor with socket erroring first 2 times" do
    run_count = 0
    WebMock.stub_request(:get, /\w/).and_return(
      lambda do |request|
        run_count += 1
        if run_count <= 2 # First 5 calls fail.
          raise Excon::Error::Socket, Exception.new("Mock Error")
        else
          { body: request.body, headers: request.headers, status: 200 }
        end
      end
    )

    # NOTE: A short :retry_interval will avoid slowing down the tests.
    response = connection.request(method: :get, idempotent: true, path: '/some-path', retry_limit: 3, retry_interval: 0.1)
    expect(response.status).to eq(200)
  end

  it "Retry limit and sleep in constructor with socket erroring first 2 times" do
    run_count = 0
    WebMock.stub_request(:get, /\w/).and_return(
      lambda do |request|
        run_count += 1
        if run_count <= 2 # First 5 calls fail.
          raise Excon::Error::Socket, Exception.new("Mock Error")
        else
          { body: request.body, headers: request.headers, status:  200 }
        end
      end
    )

    # NOTE: A short :retry_interval will avoid slowing down the tests.
    expect {
      connection.request(method: :get, idempotent: true, path: '/some-path', retry_limit: 2, retry_interval: 0.1)
    }.to raise_error(Excon::Error::Socket)
  end

  it "Idempotent request with custom error first 3 times" do
    run_count = 0
    WebMock.stub_request(:get, /\w/).and_return(
      lambda do |request|
        run_count += 1
        if run_count <= 3 # First 3 calls fail.
          raise "oops"
        else
          { body: request.body, headers: request.headers, status: 200 }
        end
      end
    )

    response = connection.request(method: :get, idempotent: true, retry_errors: [RuntimeError], path: '/some-path')
    expect(response.status).to eq(200)
  end

  it("Idempotent request with custom error first 5 times") do
    run_count = 0
    WebMock.stub_request(:get, /\w/).and_return(
      lambda do |request|
        run_count += 1
        if run_count <= 5 # First 5 calls fail.
          raise "oops"
        else
          { body: request.body, headers: request.headers, status: 200 }
        end
      end
    )

    expect {
      connection.request(method: :get, idempotent: true, retry_errors: [RuntimeError], path: '/some-path')
    }.to raise_error(RuntimeError)
  end

  it "Overriding default retry_errors" do
    WebMock.stub_request(:get, /\w/).to_raise(
      Excon::Error::Socket.new(Exception.new "Mock Error")
    )

    expect {
      connection.request(method: :get, idempotent: true, retry_errors: [RuntimeError], path: '/some-path')
    }.to raise_error(Excon::Error::Socket)
  end

  it "request_block rewound" do
    run_count = 0
    WebMock.stub_request(:get, /\w/).and_return(
      lambda do |request|
        run_count += 1
        if run_count <= 1 # First call fails.
          raise Excon::Error::Socket, Exception.new("Mock Error")
        else
          { body: request.body, headers: request.headers, status: 200 }
        end
      end
    )
    request_block = block_class.new
    connection.request(method: :get, idempotent: true, path: '/some-path', request_block:, retry_limit: 2, retry_interval: 0.1)
    expect(request_block.rewound).to eq(true)
  end

  it "response_block rewound" do
    run_count = 0
    WebMock.stub_request(:get, /\w/).and_return(
      lambda do |request|
        run_count += 1
        if run_count <= 1 # First call fails.
          raise Excon::Error::Socket, Exception.new("Mock Error")
        else
          { body: request.body, headers: request.headers, status: 200 }
        end
      end
    )
    response_block = block_class.new
    connection.request(method: :get, idempotent: true, path: '/some-path', response_block:, retry_limit: 2, retry_interval: 0.1)
    expect(response_block.rewound).to eq(true)
  end
end
# rubocop:enable RSpec/RepeatedDescription
