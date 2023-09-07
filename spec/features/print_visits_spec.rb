require 'rails_helper'

RSpec.feature 'Printing a list of visits' do
  let(:cardiff)        { create(:estate, name: 'Cardiff') }
  let(:swansea)        { create(:estate, name: 'Swansea') }
  let(:swansea_prison) { create(:prison, estate: swansea) }

  let(:vst) do
    create(:booked_visit, prison: swansea_prison)
  end

  before do
    prison_login [cardiff, swansea]
    stub_auth_token
    stub_request(:get, "https://prison-api-dev.prison.service.justice.gov.uk/api/staff/485926/emails").
        to_return(body: ['joe@example.com'].to_json)
    vst.update!(slot_granted: '2017-12-21T14:00/16:00')
  end

  context 'when logging in and navigating to the print visits page' do
    it 'displays the print visit page' do
      visit new_prison_print_visit_path
      expect(page).to have_css('.navigation')
      expect(page).to have_css('label', text: 'Select one or more prisons')
    end
  end

  context 'when searching for visits with a correctly formed date' do
    let(:date) { 3.months.ago.to_date }

    it 'is a date without any visits booked in' do
      visit new_prison_print_visit_path
      fill_in 'Day', with: date.day
      fill_in 'Month', with: date.month
      fill_in 'Year', with: date.year

      click_button('Show')

      expect(page).to have_css('p', text: "No visits on #{date.to_s(:short_nomis)}")
    end

    context 'when searching for visits' do
      let(:requested_date) { 1.day.ago.to_date }
      let(:slot) { ConcreteSlot.new(requested_date.year, requested_date.month, requested_date.day, 14, 0, 16, 0).to_s }
      let!(:booked_visits)    { create_list(:booked_visit,    5, prison: swansea_prison, slot_granted: slot) }
      let!(:cancelled_visits) { create_list(:cancelled_visit, 5, prison: swansea_prison, slot_granted: slot) }

      it 'is for a date with visits' do
        visit new_prison_print_visit_path
        fill_in 'Day',   with: requested_date.day
        fill_in 'Month', with: requested_date.month
        fill_in 'Year',  with: requested_date.year

        click_button('Show')

        expect(page).to have_css('h3', text: "Visit date #{requested_date.to_s(:short_nomis)}")
        expect(page).to have_css('h3', text: 'Visit time 14:00–16:00')
        booked_visits.each do |v|
          expect(page).to have_css('tr td', text: v.prisoner_number)
        end
        cancelled_visits.each do |v|
          expect(page).to have_css('tr td', text: v.prisoner_number)
        end
      end
    end

    it 'is for a date more than six months ago' do
      visit new_prison_print_visit_path
      fill_in 'Day',   with: '21'
      fill_in 'Month', with: '12'
      fill_in 'Year',  with: '2016'
      click_button('Show')
      expect(page).to have_css('p', text: "Please choose a date within the last six months, or contact us if you would like to see older visits.")
    end
  end

  context 'when searching for visits without any date params' do
    it 'dispays a message prompting the user to search' do
      visit new_prison_print_visit_path
      click_button('Show')
      expect(page).to have_css('p', text: 'Search to generate print lists')
    end
  end
end
