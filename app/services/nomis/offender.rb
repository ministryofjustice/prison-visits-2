module Nomis
  class Offender
    include NonPersistedModel

    attribute :id

    validates_presence_of :id
  end
end
