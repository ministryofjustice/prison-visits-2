class SlotInfoPresenter
  def initialize(prison)
    self.prison = prison
  end

  def slots_for(day)
    # contains?
    slot_days = prison.slot_days.select { |sd| sd.day == day }.sort_by(&:start_date)

    active_slot_day = slot_days.detect { |sd| sd.contains?(Time.zone.today) }
    # if there is no active slot day, there are no slot times
    (active_slot_day&.slot_times || []).map do |slot_time|
      data = [slot_time.begin_hour, slot_time.begin_minute,
              slot_time.end_hour, slot_time.end_minute].map { |s| s < 10 ? "0#{s}" : s }

      "#{data[0]}#{data[1]}-#{data[2]}#{data[3]}"
    end
  end

private

  attr_accessor :prison
end
