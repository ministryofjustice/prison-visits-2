FactoryGirl.define do
  factory :offender do

    initialize_with do
      VCR.use_cassette('offender_visiting_availability-noavailability') do
        Nomis::Api.instance.lookup_active_offender(
          noms_id: 'A1459AE', date_of_birth: Date.parse('1976-06-12')
        )
      end
    end
  end

  factory :offender_not_found, class: Nomis::Offender do
    skip_create
    initialize_with do
      VCR.use_cassette('lookup_active_offender-nomatch') do
        Nomis::Api.instance.lookup_active_offender(
          noms_id: 'Z9999ZZ', date_of_birth: Date.parse('1976-06-12')
        )
      end
    end
  end
end
