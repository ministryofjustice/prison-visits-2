# frozen_string_literal: true

require 'rails_helper'
require 'shared_process_setup_context'

RSpec.feature 'Unbookable slots', :js do
  # include_context 'with a process request setup'
  let!(:prison) { create(:prison) }

  let(:next_monday) { Time.zone.today - Time.zone.today.cwday.days + 8.days }

  before do
    create(:slot_day, prison: prison, day: 'mon', slot_times: [
      build(:slot_time, begin_hour: 14, begin_minute: 0, end_hour: 16, end_minute: 10)
    ])
    create(:slot_day, prison: prison, day: 'tue', slot_times: [
      build(:slot_time, begin_hour: 9, begin_minute: 0, end_hour: 10, end_minute: 00),
      build(:slot_time, begin_hour: 14, begin_minute: 0, end_hour: 16, end_minute: 10)
    ])
    create(:unbookable_date, prison: prison, date: next_monday)

    visit staff_path
    expect(page).to have_text("Below are the social visit slots")
    click_link("Update slots for Leeds")
    # we're now on prison#show which displays unbookable slots and recurring ones
    expect(page).to have_text(next_monday.to_s(:long))
  end

  scenario 'removing a slot' do
    find("#unbookable_date_#{next_monday}").click
    expect(page).to have_current_path(prison_path(:en, prison))
    expect(Prison.find(prison.id).unbookable_dates).to eq([])
  end

  context 'with recurring' do
    let(:today) { Time.zone.today }

    context 'when editing' do
      before do
        click_link 'Mondays from 2010-01-01'
      end

      scenario 'stop monday visits soon' do
        expect {
          fill_in 'slot_day_end_date_dd', with: today.day
          fill_in 'slot_day_end_date_mm', with: today.month
          fill_in 'slot_day_end_date_yyyy', with: today.year

          click_button 'Save'
        }.not_to change(SlotDay, :count)

        expect(prison.slot_days.where(day: 'mon').first!.end_date).to eq(today)
      end
    end

    context 'without an existing slot' do
      let(:three_months_time) { today + 3.months }

      before do
        click_link 'Wednesday'
      end

      scenario 'wednesday visits for the next 3 months' do
        expect(page).to have_current_path new_prison_recurring_slot_path(:en, prison, day: :wed)

        expect {
          fill_in 'slot_day_start_date_dd', with: today.day
          fill_in 'slot_day_start_date_mm', with: today.month
          fill_in 'slot_day_start_date_yyyy', with: today.year

          fill_in 'slot_day_end_date_dd', with: three_months_time.day
          fill_in 'slot_day_end_date_mm', with: three_months_time.month
          fill_in 'slot_day_end_date_yyyy', with: three_months_time.year

          click_button 'Save'
        }.to change(SlotDay, :count).by(1)

        slot_day = prison.slot_days.where(day: 'wed').first!

        expect(slot_day.start_date).to eq(today)
        expect(slot_day.end_date).to eq(three_months_time)
      end
    end
  end

  context 'when adding a unbookable' do
    before do
      click_link 'Add Unbookable Date'
    end

    context 'with a future date' do
      let(:next_tuesday) { next_monday + 1.day }

      it 'follows happy path' do
        submit_slot_date(next_tuesday)

        expect(Prison.find(prison.id).unbookable_dates.map(&:date)).to eq([next_monday, next_tuesday])
        expect(page).to have_current_path(prison_path(:en, prison))
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
