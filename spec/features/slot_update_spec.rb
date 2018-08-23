require "rails_helper"

RSpec.feature 'Update slots for a prison', js: true do
  let(:prisons) { create_list :prison, 2 }

  let(:sso_response) do
    {
      'uid' => '1234-1234-1234-1234',
      'provider' => 'mojsso',
      'info' => {
        'first_name' => 'Joe',
        'last_name' => 'Goldman',
        'email' => 'joe@example.com',
        'permissions' => [
          { 'organisation' => prisons.first.estate.sso_organisation_name, roles: [] },
          { 'organisation' => prisons.second.estate.sso_organisation_name, roles: [] }
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
  end

  it 'displays slots per prison' do
    visit root_path
    prisons.each do |prison|
      expect(page).to have_css('h2.heading-small', text: prison.name)
      StaffInfoController::DAY_NAMES.each do |day_name|
        expect(page).to have_css('h2 + ul.slot-list li span', text: day_name)
        day = day_name[0..2].downcase
        slot_details = prison.slot_details['recurring'][day]

        if slot_details&.any?
          slot_details.each do |slot_detail|
            expect(page).to have_css('h2 + ul.slot-list li ul li', text: SlotInfoDecorator.decorate(slot_detail).formatted)
          end
        else
          expect(page).to have_css('h2 + ul.slot-list li ul li', text: I18n.t('.staff_info.no_visits.no_visits'))
        end
      end
    end
  end
end
