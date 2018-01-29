require 'typed_list/restriction_list'

class RestrictionListType < ActiveModel::Type::Value
  def cast(value)
    restrictions = value.map { |restriction| RestrictionType.new.cast(restriction) }

    RestrictionList.new(restrictions)
  end
end
