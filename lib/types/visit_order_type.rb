class VisitOrderType < ActiveModel::Type::Value
  def cast(value)
    attributes = value['type'].slice('code', 'desc')
    attributes['number'] = value['number']
    Nomis::VisitOrder.new(attributes).freeze
  end
end
