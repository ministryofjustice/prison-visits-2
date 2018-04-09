class SlotInfoDecorator < Draper::Decorator
  PARSE_REGEXP = /(\d{2})(\d{2})-(\d{2})(\d{2})/

  def formatted
    match = object.match(PARSE_REGEXP)
    [match[1], ':', match[2], ' - ', match[3], ':', match[4]].join
  end

  def to_partial_path
    'staff_info/slot_list_item'
  end
end
