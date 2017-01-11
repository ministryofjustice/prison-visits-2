# frozen_string_literal: true
class StaffInfoController < ApplicationController
  rescue_from Excon::Errors::Error, with: :handle_excon_error
  # Raised when Excon tries to parse the URI.  Will be raised if there is
  # an error or ENV['STAFF_INFO_ENDPOINT'] is not set.
  rescue_from URI::InvalidURIError, with: :not_available

  TIMEOUT = 2

  before_action :authorize_prison_request
  skip_before_action :store_current_location

  def index
    @content = fetch('/').body
  end

  # rubocop:disable Metrics/AbcSize
  def show
    page_path = params.values_at(:page, :format).compact.join('.')
    resp = fetch(page_path)

    if pdf?(resp)
      send_data(resp.body, filename: page_path, type: 'application/pdf')
    else
      @nav = markdown(fetch('nav.md').body)
      @content = markdown?(resp) ? markdown(resp.body) : resp.body
    end
  end
# rubocop:enable Metrics/AbcSize

private

  def handle_excon_error(exception)
    Rails.logger.
      warn "Staff info pages cannot be served because of #{exception}."

    if exception.class == Excon::Errors::NotFound
      not_found
    else
      not_available
    end
  end

  def not_found
    fail ActionController::RoutingError, 'Not Found'
  end

  def not_available
    render :not_available
  end

  def markdown?(resp)
    resp.headers['Content-Type'] == 'text/markdown'
  end

  def pdf?(resp)
    resp.headers['Content-Type'] == 'application/pdf'
  end

  def fetch(page_path)
    options = {
      expects: [200],
      method: :get,
      path: page_path,
      read_timeout: TIMEOUT
    }
    connection.request(options)
  end

  def connection
    @connection ||= Excon.new(
      Rails.configuration.staff_info_endpoint,
      persistent: true,
      connect_timeout: TIMEOUT
    )
  end

  def markdown(content)
    # Several of the existing pages have bad ASCII encoding. While we
    # will fix these, it is highly likely others will appear in time as
    # less experienced staff edit them using obsolete versions of Word.
    unless content.encoding == Encoding::UTF_8
      content.force_encoding('UTF-8')
    end
    content.scrub! unless content.valid_encoding?

    Redcarpet::Markdown.new(Redcarpet::Render::HTML).
      render(content)
  end
end
