# frozen_string_literal: true

# Responsible for the relationship between identities and permissions retrieved
# from SSO, and the internal Users and Estates. Also for additional information
# returned from the SSO application which is stored in the user's session.
class SignonIdentity
  class InvalidSessionData < RuntimeError; end

  ADMIN_ROLE = 'ROLE_PVB_ADMIN'
  REQUEST_ROLE = 'ROLE_PVB_REQUESTS'

  class << self
    def from_omniauth(omniauth_auth)
      info = omniauth_auth.fetch('info')

      # Disallow login unless user has access to at least one estate
      if accessible_estates(info.fetch('organisations'), info.fetch('roles')).empty?
        Rails.logger.info "User has no valid permissions: #{info}"
        return
      end

      user = find_or_create_authorized_user(info)
      additional_data = extract_additional_data(info)

      new(user, additional_data)
    end

    def from_session_data(data)
      new(
        User.find(data.fetch('user_id')),
        full_name: data.fetch('full_name'),
        logout_url: data.fetch('logout_url'),
        organisations: data.fetch('organisations'),
        roles: data.fetch('roles')
      )
    rescue KeyError
      raise InvalidSessionData
    end

  private

    # Determines which estates a user can access based on their permissions
    def accessible_estates(orgs, roles)
      mapper = EstateSSOMapper.new(orgs, roles.include?(ADMIN_ROLE))
      mapper.accessible_estates
    end

    def find_or_create_authorized_user(info)
      email = user_email(info)
      User.find_or_create_by!(email: email)
    end

    def user_email(info)
      Nomis::Api.instance.fetch_email_addresses(info.fetch('user_id')).first
    end

    def extract_additional_data(info)
      {
        full_name: full_name_from_additional_data(info),
        logout_url: "#{Rails.configuration.nomis_oauth_host}/auth/logout",
        organisations: info.fetch('organisations'),
        roles: info.fetch('roles')
      }
    end

    def full_name_from_additional_data(info)
      first_name = info.fetch('first_name')
      last_name = info.fetch('last_name')
      [first_name, last_name].reject(&:empty?).join(' ')
    end
  end

  attr_reader :user, :full_name

  def initialize(user, full_name:, logout_url:, organisations:, roles:)
    @user = user
    @full_name = full_name
    @logout_url = logout_url
    @organisations = organisations
    @roles = roles
  end

  def logout_url(redirect_to: nil)
    url = URI.parse(@logout_url)
    if redirect_to
      url.query = {
        redirect_uri: redirect_to,
        client_id: Rails.configuration.nomis_user_oauth_client_id
      }.to_query
    end

    url.to_s
  end

  def accessible_estates
    @accessible_estates ||= begin
      # Ensure that user has at least one valid role
      if @roles.select { |role| [ADMIN_ROLE, REQUEST_ROLE].include?(role) }.empty?
        []
      else
        estate_sso_mapper.accessible_estates.order(:nomis_id).to_a
      end
    end
  end

  def accessible_estates?(estates)
    estates.all? { |estate| accessible_estates.include?(estate) }
  end

  def default_estates
    # Prevent loading data from all prisons by default
    if estate_sso_mapper.admin?
      accessible_estates.take(1)
    else
      accessible_estates || fail('Should never be nil')
    end
  end

  # Export SSO data for storing in session between requests
  def to_session
    {
      'full_name' => @full_name,
      'user_id' => @user.id,
      'logout_url' => @logout_url,
      'organisations' => @organisations,
      'roles' => @roles
    }
  end

  def admin?
    @roles.include?(ADMIN_ROLE)
  end

private

  def estate_sso_mapper
    @estate_sso_mapper ||= begin
      EstateSSOMapper.new(@organisations, admin?)
    end
  end
end
