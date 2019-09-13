require 'rails_helper'

RSpec.feature 'Using the dashboard' do
  before do
    OmniAuth.config.add_mock(:mojsso, sso_response)
  end

  let(:cardiff)        { create(:estate, name: 'Cardiff') }
  let(:swansea)        { create(:estate, name: 'Swansea') }
  let(:swansea_prison) { create(:prison, estate: swansea) }
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

  context 'when logging in and switching inbox' do
    before do
      FactoryBot.create(:visit, prison: swansea_prison)
    end

    it do
      visit prison_inbox_path
      within '.prison-switcher-form' do
        select 'Cardiff', from: 'Select one or more prisons'
        unselect 'Swansea', from: 'Select one or more prisons'
        click_button 'Update'
      end

      expect(page).to have_css('.navigation', text: 'Visit requests 0')

      within '.prison-switcher-form' do
        select 'Swansea', from: 'Select one or more prisons'
        click_button 'Update'
      end

      expect(page).to have_css('.navigation', text: 'Visit requests 1')
    end
  end

  context 'when searching for a visit' do
    before do
      allow(Nomis::Api).to receive(:enabled?).and_return(false)
    end

    let!(:processed_visit) do
      create(:visit, prison: swansea_prison)
    end

    let!(:requested_visit) do
      create(:visit, prison: swansea_prison, prisoner: processed_visit.prisoner)
    end

    let!(:cancelled_visit) do
      create(:visit, :pending_nomis_cancellation, prison: swansea_prison,
                                                  prisoner: processed_visit.prisoner)
    end

    before do
      accept_visit(processed_visit, processed_visit.slots.first)
      visit prison_inbox_path
    end

    it 'finds by prisoner number' do
      fill_in 'Search', with: processed_visit.prisoner_number
      find('.button.search').click

      expect(page).to have_css("td a[href='#{prison_visit_path(requested_visit, locale: :en)}']")
      expect(page).to have_css("td a[href='#{prison_visit_path(processed_visit, locale: :en)}']")
    end

    it 'finds processed visit by human ID' do
      fill_in 'Search', with: processed_visit.human_id
      find('.button.search').click

      expect(page).to have_css("td a[href='#{prison_visit_path(processed_visit, locale: :en)}']")
    end

    it 'finds requested visit by human ID' do
      fill_in 'Search', with: requested_visit.human_id
      find('.button.search').click

      expect(page).to have_css("td a[href='#{prison_visit_path(requested_visit, locale: :en)}']")
    end

    it 'finds cancelled visit by human ID' do
      fill_in 'Search', with: cancelled_visit.human_id
      find('.button.search').click

      expect(page).to have_css("form#edit_visit_#{cancelled_visit.id}")
    end
  end

  context 'when searching for a visit and cancelling it' do
    before do
      allow(Nomis::Api).to receive(:enabled?).and_return(false)
    end

    let(:vst) do
      create(:booked_visit, prison: swansea_prison)
    end

    before do
      visit prison_inbox_path

      # Search is independent of the prison filter
      within '.prison-switcher-form' do
        unselect 'Swansea', from: 'Select one or more prisons'
        click_button 'Update'
      end
    end

    it 'sends a message and cancels the visit', vcr: { cassette_name: :cancel_visit_ga } do
      fill_in 'Search', with: vst.prisoner_number
      find('.button.search').click
      click_link 'View'

      click_button 'Send email', visible:  false

      fill_in 'Please type your message', with: 'Sandals not allowed', visible:  false
      click_button 'Send email', visible:  false

      expect(page).to have_css('.message', text: 'Sandals not allowed')

      check 'Prisoner has moved prisons'
      click_button 'Cancel visit', match: :first

      visit prison_visit_path(vst, locale: 'en')
      within '.timeline' do
        expect(page).to have_css('span', text: 'joe@example.com')
      end
    end
  end
end
