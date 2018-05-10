module PVB
  class DigitalUserConstraint
    include SSOIdentity

    def matches?(request)
      self.session = request.session

      return false unless sso_identity

      sso_identity.admin?
    end

  private

    attr_accessor :session
  end
end
