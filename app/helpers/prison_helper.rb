module PrisonHelper
  def prison_slots_on(prison, day)
    prison.slot_days.select { |sd| sd.day == day }.sort_by(&:start_date)
  end
end
