# Responsible for the relationship between identities and permissions retrieved
# from SSO, and the internal Users and Estates. Also for additional information
# returned from the SSO application which is stored in the user's session.
class SignonIdentity
  class InvalidSessionData < RuntimeError; end

  class << self
    def from_omniauth(omniauth_auth)
      info = omniauth_auth.fetch('info')

      # Disallow login unless user has access to at least one estate
      if accessible_estates(info.fetch('permissions')).empty?
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
        profile_url: data.fetch('profile_url'),
        logout_url: data.fetch('logout_url'),
        permissions: data.fetch('permissions')
      )
    rescue KeyError
      raise InvalidSessionData
    end

  private

    # Determines which estates a user can access based on their permissions
    def accessible_estates(permissions)
      orgs = permissions.map { |p| p.fetch('organisation') }

      mapper = EstateSSOMapper.new(orgs)
      mapper.accessible_estates
    end

    def find_or_create_authorized_user(info)
      email = info.fetch('email')
      User.find_or_create_by!(email: email)
    end

    def extract_additional_data(info)
      links = info.fetch('links')

      {
        full_name: full_name_from_additional_data(info),
        profile_url: links.fetch('profile'),
        logout_url: links.fetch('logout'),
        permissions: info.fetch('permissions')
      }
    end

    def full_name_from_additional_data(info)
      first_name = info.fetch('first_name')
      last_name = info.fetch('last_name')
      [first_name, last_name].reject(&:empty?).join(' ')
    end
  end

  attr_reader :user, :full_name, :profile_url

  def initialize(user, full_name:, profile_url:, logout_url:, permissions:)
    @user = user
    @full_name = full_name
    @profile_url = profile_url
    @logout_url = logout_url
    @permissions = permissions
  end

  def logout_url(redirect_to: nil)
    url = URI.parse(@logout_url)
    url.query = { redirect_to: redirect_to }.to_query if redirect_to
    url.to_s
  end

  def accessible_estates
    @accessible_estates ||= estate_sso_mapper.accessible_estates.order(:nomis_id).to_a
  end

  def accessible_estates?(estates)
    estates.all? { |estate| accessible_estates.include?(estate) }
  end

  def default_estates
    # Prevent loading data from all prisons by defaul
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
      'profile_url' => @profile_url,
      'logout_url' => @logout_url,
      'permissions' => @permissions
    }
  end

  def admin?
    estate_sso_mapper.admin?
  end

private

  def estate_sso_mapper
    @estate_sso_mapper ||= begin
      orgs = @permissions.map { |p| p.fetch('organisation') }
      EstateSSOMapper.new(orgs)
    end
  end
end
