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
      user = User.find(data.fetch('user_id'))
      new(
        user,
        full_name: data.fetch('full_name'),
        profile_url: data.fetch('profile_url'),
        logout_url: data.fetch('logout_url')
      )
    rescue KeyError
      raise InvalidSessionData
    end

  private

    # rubocop:disable Metrics/MethodLength
    def find_or_create_authorized_user(info)
      email = info.fetch('email')
      permissions = info.fetch('permissions')

      sso_orgs = permissions.map { |p| p.fetch('organisation') }
      estates = Estate.where(sso_organisation_name: sso_orgs)

      unless estates.any?
        Rails.logger.info \
          "User #{email} has no valid permissions: #{permissions}"
        return nil
      end

      User.find_or_create_by!(email: email) do |user|
        # TODO: Allow the user to access multiple estates, or to switch estates
        user.estate = estates.first
      end
    end
    # rubocop:enable Metrics/MethodLength

    def extract_additional_data(info)
      first_name = info.fetch('first_name')
      last_name = info.fetch('last_name')
      full_name = [first_name, last_name].reject(&:empty?).join(' ')

      links = info.fetch('links')

      {
        full_name: full_name,
        profile_url: links.fetch('profile'),
        logout_url: links.fetch('logout')
      }
    end
  end

  attr_reader :user, :full_name, :profile_url

  def initialize(user, full_name:, profile_url:, logout_url:)
    @user = user
    @full_name = full_name
    @profile_url = profile_url
    @logout_url = logout_url
  end

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
      'logout_url' => @logout_url
    }
  end
end
