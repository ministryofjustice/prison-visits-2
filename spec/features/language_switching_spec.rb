require 'rails_helper'

RSpec.feature 'Switching languages', type: :feature do
  scenario 'switching between available languages' do
    allow_any_instance_of(ApplicationHelper).
      to receive(:alternative_locales).and_return([:cy])

    visit booking_requests_path(locale: 'en')

    expect(page).to have_selector(
      '#proposition-name', text: 'Visit someone in prison'
    )

    allow_any_instance_of(ApplicationHelper).
      to receive(:alternative_locales).and_return([:en])

    click_on('Cymraeg')

    expect(current_path).to eq(booking_requests_path(locale: 'cy'))
    expect(page).to have_selector(
      '#proposition-name', text: 'Ymweld â rhywun yn y carchar'
    )

    click_on('English')

    expect(current_path).to eq(booking_requests_path(locale: 'en'))

    # Would have preferred to write the test using `visit('/fr/visits')` but the
    # test fails when running with `rake` but passes when running with `rspec`.
    # Seems to be a bug problem with running rspec via rake, we should try again
    # when bumping rake or rspec
    #
    # expect { visit('/fr/visits') }.
    #   to raise_error(ActionController::RouteNotFound)

    expect { booking_requests_path(locale: 'fr') }.
      to raise_error(ActionController::UrlGenerationError)
  end
end
