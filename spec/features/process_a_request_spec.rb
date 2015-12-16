require 'rails_helper'

RSpec.feature 'Processing a request', js: true do
  include ActiveJobHelper

  let(:contact_email_address) { 'visitor@test.example.com' }
  let(:prison_email_address) { 'prison@test.example.com' }
  let(:prison) {
    create(
      :prison,
      name: 'Reading Gaol',
      email_address: prison_email_address
    )
  }
  let(:vst) {
    create(
      :visit,
      prison: prison,
      contact_email_address: contact_email_address,
      prisoner: create(
        :prisoner,
        first_name: 'Oscar',
        last_name: 'Wilde'
      )
    )
  }

  before do
    visit edit_prison_visit_path(vst)
  end

  scenario 'accepting a booking' do
    find('#booking_response_selection_slot_0').click
    fill_in 'Reference number', with: '12345678'

    click_button 'Send email'

    vst.reload
    expect(vst).to be_booked
    expect(vst.reference_no).to eq('12345678')

    expect(contact_email_address).
      to receive_email.
      with_subject(/Visit confirmed: your visit for \w+ \d+ \w+ has been confirmed/).
      and_body(/Your visit to Reading Gaol is now successfully confirmed/)
    expect(prison_email_address).
      to receive_email.
      with_subject(/COPY of booking confirmation for Oscar Wilde/).
      and_body(/This is a copy of the booking confirmation email sent to the visitor/)
  end

  scenario 'rejecting a booking with no available slot' do
    choose 'None of the chosen times are available'

    click_button 'Send email'

    vst.reload
    expect(vst).to be_rejected
    expect(vst.rejection_reason).to eq('slot_unavailable')

    expect(contact_email_address).
      to receive_email.
      with_subject(/Visit cannot take place: your visit for \w+ \d+ \w+ could not be booked/).
      and_body(/none of the dates and times/)
    expect(prison_email_address).
      to receive_email.
      with_subject(/COPY of booking rejection for Oscar Wilde/).
      and_body(/This is a copy of the booking rejection email sent to the visitor/)
  end

  scenario 'rejecting a booking when the prisoner has no visiting allowance' do
    choose 'The prisoner does not have any visiting allowance (VO)'
    check 'Visiting allowance (weekends and weekday visits) (VO) will be renewed:'
    first('input[name="booking_response[allowance_renews_on]"]').click
    check 'If weekday visit (PVO) is possible instead, choose the date PVO expires:'
    first('input[name="booking_response[privileged_allowance_expires_on]"]').click

    click_button 'Send email'

    vst.reload
    expect(vst).to be_rejected
    expect(vst.rejection_reason).to eq('no_allowance')
    expect(vst.rejection.allowance_renews_on).to eq(Time.zone.today + 1)
    expect(vst.rejection.allowance_renews_on).to eq(Time.zone.today + 1)

    expect(contact_email_address).
      to receive_email.
      with_subject(/Visit cannot take place: your visit for \w+ \d+ \w+ could not be booked/).
      and_body(/not got any visiting allowance/)
    expect(prison_email_address).
      to receive_email.
      with_subject(/COPY of booking rejection for Oscar Wilde/).
      and_body(/This is a copy of the booking rejection email sent to the visitor/)
  end

  scenario 'rejecting a booking with incorrect prisoner details' do
    choose 'Prisoner details are incorrect'

    click_button 'Send email'

    vst.reload
    expect(vst.rejection_reason).to eq('prisoner_details_incorrect')
    expect(vst).to be_rejected

    expect(contact_email_address).
      to receive_email.
      with_subject(/Visit cannot take place: your visit for \w+ \d+ \w+ could not be booked/).
      and_body(/correct information for the prisoner/)
    expect(prison_email_address).
      to receive_email.
      with_subject(/COPY of booking rejection for Oscar Wilde/).
      and_body(/This is a copy of the booking rejection email sent to the visitor/)
  end

  scenario 'rejecting a booking when the prisoner has moved' do
    choose 'Prisoner no longer at the prison'

    click_button 'Send email'

    vst.reload
    expect(vst.rejection_reason).to eq('prisoner_moved')
    expect(vst).to be_rejected

    expect(contact_email_address).
      to receive_email.
      with_subject(/Visit cannot take place: your visit for \w+ \d+ \w+ could not be booked/).
      and_body(/has moved prison/)
    expect(prison_email_address).
      to receive_email.
      with_subject(/COPY of booking rejection for Oscar Wilde/).
      and_body(/This is a copy of the booking rejection email sent to the visitor/)
  end

  scenario 'rejecting a booking when the visitor is not on the contact list' do
    choose 'Visitor isn’t on the contact list'
    within '#visitor_not_on_list_details' do
      check vst.visitors.first.full_name
    end

    click_button 'Send email'

    vst.reload
    expect(vst.rejection_reason).to eq('visitor_not_on_list')
    expect(vst).to be_rejected
    expect(vst.visitors.first).to be_not_on_list

    expect(contact_email_address).
      to receive_email.
      with_subject(/Visit cannot take place: your visit for \w+ \d+ \w+ could not be booked/).
      and_body(/prisoner’s contact list/)
    expect(prison_email_address).
      to receive_email.
      with_subject(/COPY of booking rejection for Oscar Wilde/).
      and_body(/This is a copy of the booking rejection email sent to the visitor/)
  end

  scenario 'rejecting a booking when the visitor is banned' do
    choose 'Visitor is banned'
    within '#visitor_banned_details' do
      check vst.visitors.first.full_name
    end

    click_button 'Send email'

    vst.reload
    expect(vst.rejection_reason).to eq('visitor_banned')
    expect(vst).to be_rejected
    expect(vst.visitors.first).to be_banned

    expect(contact_email_address).
      to receive_email.
      with_subject(/Visit cannot take place: your visit for \w+ \d+ \w+ could not be booked/).
      and_body(/banned from visiting/)
    expect(prison_email_address).
      to receive_email.
      with_subject(/COPY of booking rejection for Oscar Wilde/).
      and_body(/This is a copy of the booking rejection email sent to the visitor/)
  end
end
