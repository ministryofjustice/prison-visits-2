FactoryBot.define do
  factory :estate do
    name do
      FFaker::AddressUK.city
    end

    sequence :nomis_id do |n|
      sprintf('%03d', n).tr('0123456789', 'ABCDEFGHIJ')
    end

    finder_slug do |e|
      e.name.parameterize
    end

    sso_organisation_name do name end

    admins { [sso_organisation_name] }
  end
end
