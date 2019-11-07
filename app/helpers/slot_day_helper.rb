# frozen_string_literal:true

module SlotDayHelper
  DAY_NAMES = %w[Monday Tuesday Wednesday Thursday Friday Saturday Sunday]
  DAYS_TO_NAMES = SlotDay::DAYS_OF_THE_WEEK.zip(DAY_NAMES).to_h

  def slot_day_edit_link_name(slot_day)
    from_link = "#{DAYS_TO_NAMES.fetch(slot_day.day)}s from #{slot_day.start_date}"
    if slot_day.end_date
      "#{from_link} to #{slot_day.end_date}"
    else
      from_link
    end
  end
end
