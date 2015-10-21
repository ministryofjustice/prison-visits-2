class AdditionalVisitor < ActiveRecord::Base
  belongs_to :visit

  validates :visit_id, :first_name, :last_name, :date_of_birth,
    presence: true
end
