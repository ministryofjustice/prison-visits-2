FactoryGirl.define do
  factory :user do
    estate

    email do
      FFaker::Internet.disposable_email
    end
  end
end
