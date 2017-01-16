# frozen_string_literal: true
FactoryGirl.define do
  factory :user do
    email do
      FFaker::Internet.disposable_email
    end
  end
end
