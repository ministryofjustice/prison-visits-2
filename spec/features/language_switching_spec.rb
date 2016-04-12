require 'rails_helper'

RSpec.feature 'Switching languages' do
  include FeaturesHelper

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

    expect { visit('/fr/request') }.
      to raise_error(ActionController::RoutingError)
  end
end
