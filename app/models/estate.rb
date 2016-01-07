class Estate < ActiveRecord::Base
  has_many :prisons

  validates :name, :nomis_id, :finder_slug, presence: true
end
