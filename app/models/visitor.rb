class Visitor < ActiveRecord::Base
  include Person

  belongs_to :visit
  validates :visit, :sort_index, presence: true

  default_scope do
    order(sort_index: :asc)
  end

  def self.banned
    where(banned: true)
  end

  def self.unlisted
    where(not_on_list: true)
  end
end
