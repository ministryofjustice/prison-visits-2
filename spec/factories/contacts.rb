FactoryBot.define do
  factory :contact, class: Nomis::Contact do
    skip_create
    id                do rand(99_999) end
    given_name        do FFaker::Name.first_name end
    surname           do FFaker::Name.last_name end
    date_of_birth     do (18..80).to_a.sample.years.ago.to_date.to_s end
    gender(code: 'M', desc: 'Male')
    relationship_type(code: 'FRI', desc: 'Friend')
    contact_type(code: 'S', desc: 'Social/Family')
    approved_visitor  true
    active            true
    restrictions([])

    trait :banned do
      restrictions {
        [
          {
            type: { 'code' => 'BAN', 'desc' => 'Banned' },
            effective_date: 2.days.ago.to_date.to_s,
            expiry_date: 1.month.from_now.to_date.to_s
          }
        ]
      }
    end

    factory :banned_contact, traits: [:banned]
  end
end
