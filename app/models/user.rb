class User < ActiveRecord::Base
  belongs_to :estate

  # TODO: Basic version implemented, left to do:
  # - Check and update permissions of existing users
  # - Don't assume that users only have access to one PVB estate
  # - Make use of SSO roles (if required)
  def self.from_sso(attrs)
    user = User.find_by email: attrs['email']
    return user if user

    sso_orgs = attrs.fetch('permissions').map { |p| p.fetch('organisation') }
    estates = Estate.where(sso_organisation_name: sso_orgs)

    return nil unless estates.any?

    # For now link the user to the first matching estate
    User.create!(estate: estates.first, email: attrs['email'])
  end
end
