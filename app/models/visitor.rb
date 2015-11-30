class Visitor < ActiveRecord::Base
  include Person

  belongs_to :visit
  validates :visit, :sort_index, presence: true

  default_scope { order(sort_index: :asc) }
end
