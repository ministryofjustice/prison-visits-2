class ErrorsController < ApplicationController
  SUPPORTED_ERRORS = {
    404 => :'404',
    406 => :'404',
    422 => :'503', # Invalid Authenticity Token
    500 => :'500',
    503 => :'503'
  }

  # Otherwise erroring POST requests can fail the CSRF check when rendering the
  # error page...
  skip_before_action :verify_authenticity_token, raise: false
  before_action :set_html_format, only: :show

  def show
    append_to_log(original_fullpath: request.original_fullpath)

    status_code = request.env['PATH_INFO'][1..-1]

    # Explicity protect against rendering an unexpected template (although such
    # a situation should not be possible with a correct routes definition)
    template_to_render = SUPPORTED_ERRORS.fetch(status_code.to_i)
    render template_to_render,
      status: status_code,
      format: :html
  end

  def test
    fail 'This is an test exception'
  end

private

  # We always want to render html back. Without this the moj_template gem errors
  # out trying to find a template of an unknown extension when requesting an
  # unknown format.
  def set_html_format
    request.format = :html
  end
end
