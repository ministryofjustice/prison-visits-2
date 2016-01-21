class ErrorsController < ApplicationController
  SUPPORTED_ERRORS = {
    404 => :'404',
    500 => :'500',
    503 => :'503'
  }

  def show
    status_code = params.fetch(:status_code).to_i

    # Explicity protect against rendering an unexpected template (although such
    # a situation should not be possible with a correct routes definition)
    template_to_render = SUPPORTED_ERRORS.fetch(status_code)

    render template_to_render, status: status_code
  end
end
