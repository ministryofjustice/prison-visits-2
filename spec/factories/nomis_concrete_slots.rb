# frozen_string_literal: true

FactoryBot.define do
  factory :nomis_concrete_slot do
    prison
    date { Time.zone.today }
    start_hour { 14 }
    start_minute { 10 }
    end_hour { 16 }
    end_minute { 30 }
  end
end
