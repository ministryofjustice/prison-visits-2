module SlotInfoHelper
  PARSE_REGEXP = /(\d{2})(\d{2})-(\d{2})(\d{2})/

  def colon_formatted_slot(object)
    match = object.match(PARSE_REGEXP)
    [match[1], ':', match[2], ' - ', match[3], ':', match[4]].join
  end
end
