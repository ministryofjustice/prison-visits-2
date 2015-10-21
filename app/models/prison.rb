class Prison < ActiveRecord::Base
  has_many :visits

  validates :name, :nomis_id, :slot_details, presence: true
  validates :enabled, inclusion: { in: [true, false] }

  def self.enabled
    where(enabled: true).order(name: :asc)
  end
end
