class AvailableSlotEnumerator
  include Enumerable

  def initialize(
    begin_date, recurring_slots, anomalous_slots, unbookable_dates, horizon = 28
  )
    @begin_date = begin_date
    @recurring_slots = recurring_slots
    @anomalous_slots = anomalous_slots
    @unbookable_dates = unbookable_dates
    @horizon = horizon
  end

  def each
    each_bookable_date do |date|
      slots_on(date).each do |slot|
        yield slot.on(date)
      end
    end
  end

private

  def each_bookable_date
    (@begin_date...(@begin_date + @horizon)).each do |date|
      yield date unless @unbookable_dates.include?(date)
    end
  end

  def slots_on(date)
    if @anomalous_slots.key?(date)
      @anomalous_slots.fetch(date)
    else
      dow = DayOfWeek.by_index(date.wday)
      @recurring_slots.fetch(dow, [])
    end
  end
end
