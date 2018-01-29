module Nomis
  class Restriction
    include MemoryModel

    BANNED_CODE = 'BAN'.freeze
    CLOSED_CODE = 'CLOSED'.freeze

    CLOSED_NAME = 'closed'.freeze

    attribute :type
    attribute :effective_date, :date
    attribute :expiry_date, :date
    attribute :comment_text, :string

    def banned?
      type['code'] == BANNED_CODE
    end

    def closed?
      type['code'] == CLOSED_CODE
    end

    def effective_at?(date)
      date >= effective_date && (expiry_date.nil? || date <= expiry_date)
    end

    def name
      return CLOSED_NAME if closed?
    end

    def description
      type['desc']
    end
  end
end
