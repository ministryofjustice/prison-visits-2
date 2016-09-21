module ControllerHelper
  def login_user(user, estate, available_estates: [estate])
    orgs = available_estates.map(&:sso_organisation_name)

    sso_identity = SignonIdentity.new(
      user,
      full_name: FFaker::Name.name,
      profile_url: '',
      logout_url: '',
      permissions: orgs.map { |o| { 'organisation' => o, 'roles' => [] } }
    )

    controller.session[:sso_data] = sso_identity.to_session
    controller.session[:current_estate] = estate.id
  end
end
