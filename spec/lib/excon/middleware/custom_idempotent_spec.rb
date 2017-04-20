require 'rails_helper'
require 'excon/middleware/custom_idempotent'

RSpec.describe Excon::Middleware::CustomIdempotent do
  let(:connection) do
    middlewares = Excon.defaults[:middlewares].map { |middleware|
      if middleware == Excon::Middleware::Idempotent
        described_class
      else
        middleware
      end
    }

    Excon.new('http://127.0.0.1:9292', middlewares: middlewares)
  end

  it "Non-idempotent call with an erroring socket"do
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

    expect { connection.request(method: :get, path: '/some-path') }.
      to raise_error(Excon::Errors::SocketError)
  end

  it "Idempotent request with a timeout error" do
    WebMock.stub_request(:get, /\w/).to_timeout
    expect { connection.request(method: :get, path: '/some-path') }.
      to raise_error(Excon::Errors::Timeout)
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

    expect { connection.request(method: :get, idempotent: true, path: '/some-path') }.
      to raise_error(Excon::Errors::SocketError)
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

    expect { connection.request(method: :get, idempotent: true, path: '/some-path', retry_limit: 2) }.
      to raise_error(Excon::Errors::SocketError)
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

    expect { connection.request(method: :get, idempotent: true, path: '/some-path', retry_limit: 8) }.
     to raise_error(Excon::Errors::SocketError)
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
end
