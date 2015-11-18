require 'rails_helper'

RSpec.describe Prison, type: :model do
  it 'enumerates available slots within booking window starting tomorrow' do
    subject.slot_details = {
      'recurring' => {
        'mon' => ['1001-1100'],
        'tue' => ['1002-1100'],
        'wed' => ['1003-1100'],
        'thu' => ['1004-1100'],
        'fri' => ['1005-1100'],
        'sat' => ['1006-1100'],
        'sun' => ['1007-1100']
      }
    }
    subject.booking_window = 5
    today = Date.new(2015, 10, 1) # Thursday
    expect(subject.available_slots(today).to_a).to eq(
      [
        ConcreteSlot.new(2015, 10, 2, 10, 5, 11, 0),
        ConcreteSlot.new(2015, 10, 3, 10, 6, 11, 0),
        ConcreteSlot.new(2015, 10, 4, 10, 7, 11, 0),
        ConcreteSlot.new(2015, 10, 5, 10, 1, 11, 0),
        ConcreteSlot.new(2015, 10, 6, 10, 2, 11, 0)
      ]
    )
  end

  it 'starts bookings tomorrow' do
    # Bookable days are 2, 3, ...
    today = Date.new(2015, 10, 1)
    expect(subject.first_bookable_date(today)).to eq(Date.new(2015, 10, 2))
  end

  it 'ends bookings at the end of the booking window, starting tomorrow' do
    # Bookable days are 2, 3, 4, 5, 6
    subject.booking_window = 5
    today = Date.new(2015, 10, 1)
    expect(subject.last_bookable_date(today)).to eq(Date.new(2015, 10, 6))
  end
end
