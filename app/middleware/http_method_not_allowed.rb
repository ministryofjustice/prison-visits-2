class HttpMethodNotAllowed
  def initialize(app)
    @app = app
  end

  def call(env)
    if !env['REQUEST_METHOD'].upcase.in? ActionDispatch::Request::HTTP_METHODS
      Rails.logger.info("Unknown Http Method: #{env['REQUEST_METHOD']}")
      [405, { 'Content-Type' => 'text/plain' }, ['Method Not Allowed']]
    else
      @app.call(env)
    end
  end
end
