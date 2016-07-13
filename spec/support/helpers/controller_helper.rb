module ControllerHelper
  def stub_logged_in_user(user)
    allow(controller).to receive(:current_user).and_return(user)
  end
end
