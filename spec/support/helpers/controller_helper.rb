module ControllerHelper
  def stub_logged_in_user(user)
    identity = SignonIdentity.new(user, full_name: FFaker::Name.name, profile_url: '', logout_url: '')
    allow(controller).to receive(:sso_identity).and_return(identity)
  end
end
