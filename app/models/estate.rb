# read-only object initialised from db:seeds
class Estate < ApplicationRecord
  has_many :prisons, dependent: :restrict_with_exception

  # finder_slug is an override for the Prison Finder URL
  validates :name, :nomis_id, :finder_slug, presence: true
end
