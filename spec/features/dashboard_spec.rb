require 'rails_helper'

RSpec.feature 'Using the dashboard' do
  before do
    OmniAuth.config.add_mock(:mojsso, sso_response)
  end

  let(:cardiff) { FactoryGirl.create(:estate, name: 'Cardiff') }
  let(:swansea) { FactoryGirl.create(:estate, name: 'Swansea') }
  let(:swansea_prison) { FactoryGirl.create(:prison, estate: swansea) }
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

  context 'log in and switch inbox' do
    before do
      FactoryGirl.create(:visit, prison: swansea_prison)
    end

    it do
      visit prison_inbox_path

      within '.prison-switcher-form' do
        select 'Cardiff', from: 'Select one or more prisons'
        click_button 'Update'
      end

      expect(page).to have_css('.navigation', 'Inbox 0')

      within '.prison-switcher-form' do
        select 'Swansea', from: 'Select one or more prisons'
        click_button 'Update'
      end

      expect(page).to have_css('.navigation', 'Inbox 1')
    end
  end

  context 'searching a visit' do
    before do
      allow(Nomis::Api).to receive(:enabled?).and_return(false)
    end

    let!(:processed_visit) do
      create(:visit, prison: swansea_prison)
    end

    let!(:requested_visit) do
      create(:visit, prison: swansea_prison, prisoner: processed_visit.prisoner)
    end

    before do
      accept_visit(processed_visit, processed_visit.slots.first)

      visit prison_inbox_path
    end

    it 'displays the search results' do
      fill_in 'Search', with: processed_visit.prisoner_number
      find('.button.search').click

      expect(page).to have_css("td a[href='#{prison_visit_process_path(requested_visit, locale: :en)}']")
      expect(page).to have_css("td a[href='#{prison_visit_path(processed_visit, locale: :en)}']")
    end
  end

  context 'searching a visit and cancelling it' do
    before do
      allow(Nomis::Api).to receive(:enabled?).and_return(false)
    end

    let(:vst) do
      FactoryGirl.create(:booked_visit, prison: swansea_prison)
    end

    before do
      visit prison_inbox_path

      # Search is independent of the prison filter
      within '.prison-switcher-form' do
        unselect 'Swansea', from: 'Select one or more prisons'
        click_button 'Update'
      end
    end

    it 'sends a message and cancels the visit' do
      fill_in 'Search', with: vst.prisoner_number
      find('.button.search').click
      click_link 'View'

      click_button 'Send email'

      fill_in 'Please type your message', with: 'Sandals not allowed'
      click_button 'Send email'

      expect(page).to have_css('.message', 'Sandals not allowed')

      find('.summary', text: 'Issue with the prisoner').click
      choose 'Prisoner has moved prisons'
      click_button 'Cancel visit', match: :first

      visit prison_visit_path(vst)
      within '.timeline' do
        expect(page).to have_css('span', text: 'joe@example.com')
      end
    end
  end
end
