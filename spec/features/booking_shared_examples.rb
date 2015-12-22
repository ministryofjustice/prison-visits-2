RSpec.shared_examples 'make a booking' do
  scenario do
    find('#booking_response_selection_slot_0').click
    fill_in 'Reference number', with: '12345678'

    click_button 'Send email'

    vst.reload
    expect(vst).to be_booked
    expect(vst.reference_no).to eq('12345678')

    expect(visitor_email_address).
      to receive_email.
      with_subject(/Visit confirmed: your visit for \w+ \d+ \w+ has been confirmed/).
      and_body(/Your visit to Reading Gaol is now successfully confirmed/)
    expect(prison_email_address).
      to receive_email.
      with_subject(/COPY of booking confirmation for Oscar Wilde/).
      and_body(/This is a copy of the booking confirmation email sent to the visitor/)
  end
end
