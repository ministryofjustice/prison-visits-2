# Responsible for the relationship between identities and permissions retrieved
# from SSO, and the internal Users and Estates. Also for additional information
# returned from the SSO application which is stored in the user's session.
class SignonIdentity
  class InvalidSessionData < RuntimeError; end

  class << self
    def from_omniauth(omniauth_auth)
      info = omniauth_auth.fetch('info')
      user = find_or_create_authorized_user(info)
      return unless user

      additional_data = extract_additional_data(info)
      new(user, **additional_data)
    end

    def from_session_data(data)
      new(
        User.find(data.fetch('user_id')),
        full_name: data.fetch('full_name'),
        profile_url: data.fetch('profile_url'),
        logout_url: data.fetch('logout_url'),
        available_organisations: data.fetch('available_organisations'),
        current_organisation: data.fetch('current_organisation')
      )
    rescue KeyError
      raise InvalidSessionData
    end

  private

    def find_or_create_authorized_user(info)
      email = info.fetch('email')
      sso_orgs = valid_pvb_orgs(info)

      unless sso_orgs.any?
        permissions = info.fetch('permissions')
        Rails.logger.info \
          "User #{email} has no valid permissions: #{permissions}"
        return nil
      end

      User.find_or_create_by!(email: email)
    end

    def extract_additional_data(info)
      links = info.fetch('links')
      sso_orgs = valid_pvb_orgs(info)

      {
        full_name: full_name_from_additional_data(info),
        profile_url: links.fetch('profile'),
        logout_url: links.fetch('logout'),
        available_organisations: sso_orgs,
        current_organisation: sso_orgs.first
      }
    end

    def full_name_from_additional_data(info)
      first_name = info.fetch('first_name')
      last_name = info.fetch('last_name')
      [first_name, last_name].reject(&:empty?).join(' ')
    end

    def valid_pvb_orgs(info)
      sso_orgs = info.fetch('permissions').map { |p| p.fetch('organisation') }
      pvb_orgs = Estate.pluck(:sso_organisation_name)
      sso_orgs.select { |org| pvb_orgs.include?(org) }
    end
  end

  attr_reader :user, :full_name, :profile_url

  # rubocop:disable ParameterLists
  def initialize(user, full_name:, profile_url:, logout_url:,
    available_organisations:, current_organisation:)
    @user = user
    @full_name = full_name
    @profile_url = profile_url
    @logout_url = logout_url
    @available_organisations = available_organisations
    @current_organisation = current_organisation
  end
  # rubocop:enable ParameterLists

  def logout_url(redirect_to: nil)
    url = URI.parse(@logout_url)
    url.query = { redirect_to: redirect_to }.to_query if redirect_to
    url.to_s
  end

  # Export SSO data for storing in session between requests
  def to_session
    {
      'full_name' => @full_name,
      'user_id' => @user.id,
      'profile_url' => @profile_url,
      'logout_url' => @logout_url,
      'available_organisations' => @available_organisations,
      'current_organisation' => @current_organisation
    }
  end

  def current_estate
    @current_estate ||=
      Estate.find_by!(sso_organisation_name: @current_organisation)
  end
end
