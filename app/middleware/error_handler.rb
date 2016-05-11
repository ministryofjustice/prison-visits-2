# Our Rails exception_app is a Rails controller action. As such it tries to
# parse the params before processing the action, to do this it relies on Rack,
# which raises an error if the query string is invalid.
#
# To stop the error bubbling out into an unstyled 500 page we need to modify the
# 'env' to clear the query string before calling the action.
class ErrorHandler
  def self.call(env)
    unless valid_query_string?(env['QUERY_STRING'])
      env['QUERY_STRING'] = ''
    end

    ErrorsController.action(:show).call(env)
  rescue => e
    Raven.capture_exception(e)
    raise
  end

  def self.valid_query_string?(query_string)
    Rack::Utils.parse_nested_query(query_string)
    true
  rescue
    false
  end
end
