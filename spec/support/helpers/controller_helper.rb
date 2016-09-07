module ControllerHelper
  def stub_logged_in_user(user, estate, available_estates: [estate], available_orgs: [])
    orgs = if available_orgs.any?
             available_orgs
           else
             available_estates.map(&:sso_organisation_name)
           end

    sso_identity = SignonIdentity.new(
      user,
      full_name: FFaker::Name.name,
      profile_url: '',
      logout_url: '',
      current_organisation: estate.sso_organisation_name,
      available_organisations: orgs
    )

    controller.session[:sso_data] = sso_identity.to_session
  end
end
