FactoryBot.define do
  factory :prisoner do
    first_name do
      FFaker::Name.first_name
    end

    last_name do
      FFaker::Name.last_name
    end

    date_of_birth do '1970-01-01' end

    sequence(:number) do |n|
      sprintf('ABC%04d', n)
    end
  end
end
