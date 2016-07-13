class User < ActiveRecord::Base
  belongs_to :estate

  # TODO: Basic version implemented, left to do:
  # - Check and update permissions of existing users
  # - Don't assume that users only have access to one PVB estate
  def self.from_sso(attrs)
    user = User.find_by email: attrs['email']
    return user if user

    sso_org_name = attrs['permissions'].first.try(:[], 'organisation')
    estate = Estate.find_by(sso_organisation_name: sso_org_name)

    return nil unless estate

    User.create!(estate: estate, email: attrs['email'])
  end
end
