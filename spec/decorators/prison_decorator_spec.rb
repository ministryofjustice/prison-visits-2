require "rails_helper"

RSpec.describe PrisonDecorator do
  let(:prison) { create :prison }

  subject {  prison.decorate }

  describe '#recurring_slot_list_for' do
    let(:html_fragment) { Capybara.string(subject.recurring_slot_list_for(day)) }

    context 'with a day without recurring slots' do
      let(:day) { 'wed' }

      it 'show "no visits"' do
        expect(html_fragment).to have_css('li', text: I18n.t('.staff_info.no_visits.no_visits'))
      end
    end

    context 'when a day has recurriong visits' do
      let(:day) { 'mon' }

      it 'displays the slot list' do
        SlotInfoPresenter.slots_for(prison, day).each do |slot_info|
          expect(html_fragment).to have_css('li', text: subject.h.colon_formatted_slot(slot_info))
        end
      end
    end
  end
end
