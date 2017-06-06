FactoryGirl.define do
  factory :lead_visitor, parent: :visitor, class: LeadVisitor do
    visit { create :visit }
  end
end
