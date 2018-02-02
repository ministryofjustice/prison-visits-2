require 'maybe_date'
class PrintVisits
  include NonPersistedModel

  attribute :visit_date, MaybeDate
end
