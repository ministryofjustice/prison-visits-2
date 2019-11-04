FactoryBot.define do
  factory :estate do
    name do
      FFaker::AddressUK.city
    end

    # This field is only 3 characters - wrapping after 1000 unique ones
    # in tests feels reasonable as they are destroyed quite often
    sequence :nomis_id do |n|
      estate_id = n % 1000

      ('%03d' % estate_id).tr('0123456789', 'ABCDEFGHIJ')
    end

    finder_slug do |e|
      e.name.parameterize
    end

    sso_organisation_name do name end

    admins { [sso_organisation_name] }
  end
end
