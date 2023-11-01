require 'rails_helper'

RSpec.shared_context 'when accepting a request' do
  before do
    staff_response.selection = 'slot_0'
    staff_response.reference_no = '1337807'
  end

  it 'changes the status of the visit to booked' do
    expect(visit_after_responding).to be_booked
  end

  it 'sets the reference number of the visit' do
    expect(visit_after_responding.reference_no).to eq('1337807')
  end

  it 'marks the visit as closed' do
    staff_response.closed_visit = true
    expect(visit_after_responding).to be_closed
  end

  it 'marks the visit as not closed' do
    staff_response.closed_visit = false
    expect(visit_after_responding).not_to be_closed
  end

  it 'emails the visitor' do
    expect(VisitorMailer).to receive(:booked).with(visit)
      .and_return(mailing)
    expect(mailing).to receive(:deliver_later)
    subject.respond!
  end

  context 'with the first slot' do
    before do
      staff_response.selection = 'slot_0'
    end

    it 'assigns the selected slot' do
      expect(visit_after_responding.slot_granted)
        .to eq(visit_after_responding.slots[0])
    end
  end

  context 'with the second slot' do
    before do
      staff_response.selection = 'slot_1'
    end

    it 'assigns the selected slot' do
      expect(visit_after_responding.slot_granted)
        .to eq(visit_after_responding.slots[1])
    end
  end

  context 'with the third slot' do
    before do
      staff_response.selection = 'slot_2'
    end

    it 'assigns the selected slot' do
      expect(visit_after_responding.slot_granted)
        .to eq(visit_after_responding.slots[2])
    end
  end
end
