ActiveModel::Type.register(:accessible_date,                 AccessibleDateType)
ActiveModel::Type.register(:api_slot_list,                   ApiSlotListType)
ActiveModel::Type.register(:availability_visit_list,         AvailabilityVisitListType)
ActiveModel::Type.register(:concrete_slot,                   ConcreteSlotType)
ActiveModel::Type.register(:concrete_slot_list,              ConcreteSlotListType)
ActiveModel::Type.register(:contacts_enumerable,             ContactsEnumerableType)
ActiveModel::Type.register(:date_list,                       DateListType)
ActiveModel::Type.register(:nomis_offender,                  NomisOffenderType)
ActiveModel::Type.register(:normalised_concrete_slot,        NormalisedConcreteSlotType)
ActiveModel::Type.register(:prison,                          PrisonType)
ActiveModel::Type.register(:prisoner_number,                 PrisonerNumberType)
ActiveRecord::Type.register(:prisoner_number,                PrisonerNumberType)
ActiveModel::Type.register(:prisoner_date_availability_list, PrisonerDateAvailabilityListType)
ActiveModel::Type.register(:restriction,                     RestrictionType)
ActiveModel::Type.register(:restriction_list,                RestrictionListType)
ActiveModel::Type.register(:visitor_list,                    VisitorListType)
ActiveModel::Type.register(:level_list,                      LevelListType)
ActiveModel::Type.register(:housing_location,                HousingLocationType)
