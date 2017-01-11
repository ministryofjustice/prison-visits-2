# frozen_string_literal: true
FactoryGirl.define do
  factory :message do
    user
    visit
    body 'a staff message to the user'
  end
end
