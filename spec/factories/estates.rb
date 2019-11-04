FactoryBot.define do
  factory :estate do
    name do
      FFaker::AddressUK.city
    end

    sequence :nomis_id do |n|
      name_chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
      name_chars.gsub! name_chars.first(n / 1000), ''

      ('%03d' % (n % 1000)).tr('0123456789', name_chars)
    end

    finder_slug do |e|
      e.name.parameterize
    end

    sso_organisation_name do name end

    admins { [sso_organisation_name] }
  end
end
