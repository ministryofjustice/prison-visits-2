require 'rails_helper'
require 'shared_process_setup_context'

RSpec.feature 'Unbookable slots', :js do
  include_context 'with a process request setup'

  let(:next_monday) { Time.zone.today - Time.zone.today.cwday.days + 8.days }

  before do
    prison.update!(slot_details:
                     { 'recurring' => {
                       'mon' => ['1400-1610'],
                       'tue' => %w[0900-1000 1400-1610]
                     } }
    )
    create(:unbookable_date, prison: prison, date: next_monday)

    visit staff_path
    expect(page).to have_text("Below are the social visit slots")
    click_link("Update slots for Leeds")
    expect(page).to have_text(next_monday.to_s(:long))
  end

  context 'when removing a slot' do
    it 'destroys' do
      find("#unbookable_date_#{next_monday}").click
      expect(page).to have_current_path('/staff?locale=en')
      expect(Prison.find(prison.id).unbookable_dates).to eq([])
    end
  end

  context 'when adding a slot' do
    before do
      click_link 'Add Unbookable Date'
    end

    context 'with a future date' do
      let(:next_tuesday) { next_monday + 1.day }

      it 'follows happy path' do
        submit_slot_date(next_tuesday)

        expect(Prison.find(prison.id).unbookable_dates.map(&:date)).to eq([next_monday, next_tuesday])
        expect(page).to have_current_path('/staff?locale=en')
      end
    end

    context 'when slot date in the past' do
      let(:slot_date) { Time.zone.today - 2.days }

      it 'bounces' do
        submit_slot_date(slot_date)

        expect(page).to have_current_path(prison_unbookable_dates_path('en', prison))
        expect(page).to have_css('.error-message')
      end
    end
  end

  def submit_slot_date(future)
    fill_in id: 'unbookable_date_date_dd', with: future.day
    fill_in id: 'unbookable_date_date_mm', with: future.month
    fill_in id: 'unbookable_date_date_yyyy', with: future.year

    click_button 'Save'
  end
end
