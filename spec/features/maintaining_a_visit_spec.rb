require 'rails_helper'

RSpec.feature 'Maintaining a visit', js: true do
  scenario 'viewing and withdrawing a visit request' do
    vst = create(:visit)
    visit visit_path(vst)
    expect(page).to have_text('Your visit is not booked yet')

    check 'Yes, I want to cancel this visit'
    click_button 'Cancel request'
    expect(vst.reload).to be_withdrawn
    expect(page).to have_text('You cancelled this visit request')
  end

  scenario 'viewing and cancelling a booked visit' do
    vst = create(:booked_visit)
    visit visit_path(vst)
    expect(page).to have_text('Your visit has been confirmed')

    check 'Yes, I want to cancel this visit'
    click_button 'Cancel visit'
    expect(vst.reload).to be_canceled
    expect(page).to have_text('You cancelled this visit')
  end

  scenario 'viewing a rejected visit' do
    vst = create(:rejected_visit)
    visit visit_path(vst)
    expect(page).to have_text('Your visit request cannot take place')

    click_link 'new visit'
    expect(current_path).to eq(booking_requests_path)
  end

  scenario 'viewing a withdrawn visit and trying again' do
    vst = create(:withdrawn_visit)
    visit visit_path(vst)
    expect(page).to have_text('You cancelled this visit request')

    click_link 'new visit'
    expect(current_path).to eq(booking_requests_path)
  end

  scenario 'viewing a cancelled visit and trying again' do
    vst = create(:canceled_visit)
    visit visit_path(vst)
    expect(page).to have_text('You cancelled this visit')

    click_link 'new visit'
    expect(current_path).to eq(booking_requests_path)
  end
end
