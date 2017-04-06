module Nomis
  class ContactRestriction
    include NonPersistedModel

    BANNED_CODE = 'BAN'.freeze

    attribute :type, Hash[Symbol => String]
    attribute :effective_date, Date
    attribute :expiry_date, Date

    def banned?
      type[:code] == BANNED_CODE
    end
  end
end
