# frozen_string_literal: true

FactoryBot.define do
  factory :nomis_concrete_slot do
    prison
    date do Time.zone.today end
    start_hour do 14 end
    start_minute do 10 end
    end_hour do 16 end
    end_minute { 30 }
  end
end
