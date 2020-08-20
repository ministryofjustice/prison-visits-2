module SlotInfoHelper
  DAYS_OF_THE_WEEK = %w[mon tue wed thu fri sat sun].freeze
  DAY_NAMES = %w[Monday Tuesday Wednesday Thursday Friday Saturday Sunday].freeze
  DAYS_TO_NAMES = DAYS_OF_THE_WEEK.zip(DAY_NAMES).to_h

  PARSE_REGEXP = /(\d{2})(\d{2})-(\d{2})(\d{2})/

  def colon_formatted_slot(object)
    match = object.match(PARSE_REGEXP)
    [match[1], ':', match[2], ' - ', match[3], ':', match[4]].join
  end
end
