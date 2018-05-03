module PVB
  class DigitalUserConstraint
    include SSOIdentity

    def matches?(request)
      self.session = request.session
      sso_identity.pvb_admin?
    end

  private

    attr_accessor :session
  end
end
