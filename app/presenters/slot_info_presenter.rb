class SlotInfoPresenter
  def initialize(prison)
    self.prison = prison
  end

  def slots_for(day)
    slot_days = prison.slot_days.select { |sd| sd.day == day }.sort_by(&:start_date)

    today = Time.zone.today

    active_slot_day = slot_days.detect { |sd| today >= sd.start_date }
    # if there is no active slot day, there are no slot times
    (active_slot_day&.slot_times || []).map do |slot_time|
      data = [slot_time.start_hour, slot_time.start_minute,
              slot_time.end_hour, slot_time.end_minute].map { |s| s < 10 ? "0#{s}" : s }

      "#{data[0]}#{data[1]}-#{data[2]}#{data[3]}"
    end
  end

private

  attr_accessor :prison
end
