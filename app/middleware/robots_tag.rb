# frozen_string_literal: true

class RobotsTag
  X_ROBOT_TAG_HEADER_VALUE = 'none'
  X_ROBOT_TAG_HEADER = 'X-Robots-Tag'

  def initialize(app)
    @app = app
  end

  def call(env)
    status, headers, response = @app.call(env)
    headers[X_ROBOT_TAG_HEADER] = X_ROBOT_TAG_HEADER_VALUE

    [status, headers, response]
  end
end
