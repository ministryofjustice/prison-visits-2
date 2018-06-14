require 'rails_helper'

RSpec.feature 'Printing a list of visits' do
  let(:cardiff)        { create(:estate, name: 'Cardiff') }
  let(:swansea)        { create(:estate, name: 'Swansea') }
  let(:swansea_prison) { create(:prison, estate: swansea) }

  let(:vst) do
    create(:booked_visit, prison: swansea_prison)
  end

  let(:sso_response) do
    {
      'uid' => '1234-1234-1234-1234',
      'provider' => 'mojsso',
      'info' => {
        'first_name' => 'Joe',
        'last_name' => 'Goldman',
        'email' => 'joe@example.com',
        'permissions' => [
          { 'organisation' => cardiff.sso_organisation_name, roles: [] },
          { 'organisation' => swansea.sso_organisation_name, roles: [] }
        ],
        'links' => {
          'profile' => 'http://example.com/profile',
          'logout' => 'http://example.com/logout'
        }
      }
    }
  end

  before do
    OmniAuth.config.add_mock(:mojsso, sso_response)
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
    it 'is a date without any visits booked in' do
      visit new_prison_print_visit_path
      fill_in 'Day', with: '23'
      fill_in 'Month', with: '01'
      fill_in 'Year', with: '2018'
      click_button('Show')
      expect(page).to have_css('p', text: 'No visits on 23/01/2018')
    end

    it 'is for a date with visits' do
      visit new_prison_print_visit_path
      fill_in 'Day', with: '21'
      fill_in 'Month', with: '12'
      fill_in 'Year', with: '2017'
      click_button('Show')
      expect(page).to have_css('h3', text: 'Visit date 21/12/2017')
      expect(page).to have_css('h3', text: 'Visit time 14:00–16:00')
    end

    it 'is for a date more than six months ago' do
      visit new_prison_print_visit_path
      fill_in 'Day', with: '21'
      fill_in 'Month', with: '12'
      fill_in 'Year', with: '2016'
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
