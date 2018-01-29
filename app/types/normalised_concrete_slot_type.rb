class NormalisedConcreteSlotType < ConcreteSlotType
  def cast(value)
    Nomis::ApiSlotNormaliser.new(value).slot
  end
end
