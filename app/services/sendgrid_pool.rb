class SendgridPool
  include Singleton

  def configure(client_attrs:, size: 5, timeout: 1)
    fail 'already configured' if @pool

    @pool = ConnectionPool.new(size: size, timeout: timeout) do
      SendgridClient.new(
        api_key: client_attrs.fetch(:api_key),
        api_user: client_attrs.fetch(:api_user),
        http_opts: client_attrs.fetch(:http_opts)
      )
    end
  end

  def with(timeout: nil)
    @pool.with(timeout: timeout) do |conn|
      yield conn
    end
  end
end
