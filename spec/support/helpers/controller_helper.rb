module ControllerHelper
  def stub_logged_in_user(user, estate)
    allow(controller).to receive(:sso_identity) do
      SignonIdentity.new(
        user,
        full_name: FFaker::Name.name,
        profile_url: '',
        logout_url: '',
        current_organisation: estate.sso_organisation_name,
        available_organisations: [estate.sso_organisation_name])
    end
  end
end
