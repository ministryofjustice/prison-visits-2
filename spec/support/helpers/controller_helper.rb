module ControllerHelper
  def stub_logged_in_user(user, estate, available_estates = [estate])
    sso_identity = SignonIdentity.new(
      user,
      full_name: FFaker::Name.name,
      profile_url: '',
      logout_url: '',
      current_organisation: estate.sso_organisation_name,
      available_organisations: available_estates.map(&:sso_organisation_name)
    )

    controller.session[:sso_data] = sso_identity.to_session
  end
end
