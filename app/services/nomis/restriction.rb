module Nomis
  class Restriction
    include NonPersistedModel

    BANNED_CODE = 'BAN'.freeze
    CLOSED_CODE = 'CLOSED'.freeze

    CLOSED_NAME = 'closed'.freeze

    attribute :type, Hash[Symbol => String]
    attribute :effective_date, Date
    attribute :expiry_date, Date
    attribute :comment_text, String

    def banned?
      type[:code] == BANNED_CODE
    end

    def closed?
      type[:code] == CLOSED_CODE
    end

    def effective_at?(date)
      date >= effective_date && (expiry_date.nil? || date <= expiry_date)
    end

    def name
      return CLOSED_NAME if closed?
    end

    def description
      type[:desc]
    end
  end
end
