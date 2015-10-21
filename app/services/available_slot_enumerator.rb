class AvailableSlotEnumerator
  include Enumerable

  def initialize(begin_date, regular_slots, unbookable_dates, horizon = 28)
    @begin_date = begin_date
    @regular_slots = regular_slots
    @unbookable_dates = unbookable_dates
    @horizon = horizon
  end

  def each
    (@begin_date...(@begin_date + @horizon)).each do |date|
      next if @unbookable_dates.include?(date)
      dow = DayOfWeek.by_index(date.wday)
      @regular_slots.fetch(dow, []).each do |slot|
        yield slot.on(date)
      end
    end
  end
end
