module Nomis
  class ContactRestriction
    include NonPersistedModel

    attribute :type, Hash[Symbol => String]
    attribute :effective_date, Date
    attribute :expiry_date, Date
  end
end
