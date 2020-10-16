class NomisConcreteSlot < ApplicationRecord
  belongs_to :prison, inverse_of: :nomis_concrete_slots
end
