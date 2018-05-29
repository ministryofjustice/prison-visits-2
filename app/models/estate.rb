class Estate < ApplicationRecord
  has_many :prisons, dependent: :restrict_with_exception

  validates :name, :nomis_id, :finder_slug, presence: true
end
