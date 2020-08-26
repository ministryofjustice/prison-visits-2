module ControllerHelper
  def login_user(user, current_estates:, available_estates: [current_estates.first])
    orgs = available_estates.map(&:nomis_id)

    sso_identity = SignonIdentity.new(
      user,
      full_name: FFaker::Name.name,
      roles: [],
      logout_url: '',
      organisations: orgs
    )

    controller.session[:sso_data] = sso_identity.to_session
    controller.session[:current_estates] = current_estates.map(&:id)
  end
end
