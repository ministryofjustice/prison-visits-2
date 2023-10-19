require 'rails_helper'

RSpec.feature 'Using the dashboard' do
  before do
    prison_login [cardiff, swansea]
    stub_auth_token
    stub_request(:get, "https://prison-api-dev.prison.service.justice.gov.uk/api/staff/485926/emails")
        .to_return(body: ['joe@example.com'].to_json)
  end

  let(:cardiff)        { create(:estate, name: 'Cardiff') }
  let(:swansea)        { create(:estate, name: 'Swansea') }
  let(:swansea_prison) { create(:prison, estate: swansea) }

  context 'when logging in and switching inbox' do
    before do
      create(:visit, prison: swansea_prison)
    end

    it do
      visit prison_inbox_path

      within '.prison-switcher-form' do
        select_from_chosen 'Cardiff', from: 'Select one or more prisons'
        unselect_from_chosen 'Swansea', from: 'Select one or more prisons'
        click_button 'Update'
      end

      expect(page).to have_css('.navigation', text: 'Visit requests 0')

      within '.prison-switcher-form' do
        select_from_chosen 'Swansea', from: 'Select one or more prisons'
        click_button 'Update'
      end

      expect(page).to have_css('.navigation', text: 'Visit requests 1')
    end
  end

  context 'when searching for a visit' do
    before do
      # Instantiate a Nomis::Api instance before stubbing Nomis::Api.enabled?
      # otherwise an exception will be raised

      Nomis::Api.instance

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
      visit prison_inbox_path
    end

    before do
      allow(Nomis::Api).to receive(:enabled?).and_return(false)
    end

    let(:vst) do
      create(:booked_visit, prison: swansea_prison)
    end

    before do
      # Search is independent of the prison filter
      within '.prison-switcher-form' do
        unselect_from_chosen 'Swansea', from: 'Select one or more prisons'
        click_button 'Update'
      end
    end

    it 'sends a message and cancels the visit', vcr: { cassette_name: :cancel_visit_ga } do
      fill_in 'Search', with: vst.prisoner_number
      find('.button.search').click
      click_link 'View'

      find_button('Send email').trigger('click')

      fill_in 'Please type your message', with: 'Sandals not allowed', visible:  false
      find_button('Send email').trigger('click')

      expect(page).to have_css('.message', text: 'Sandals not allowed')

      check 'Prisoner has moved prisons', visible: false

      click_button 'Cancel visit', match: :first

      visit prison_visit_path(vst, locale: 'en')
      within '.timeline' do
        expect(page).to have_css('span', text: 'joe@example.com')
      end
    end
  end
end
