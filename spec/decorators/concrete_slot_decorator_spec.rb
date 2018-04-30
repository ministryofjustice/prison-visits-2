require "rails_helper"

RSpec.describe ConcreteSlotDecorator do
  let(:visit) { create(:visit) }
  let(:slot_errors)   { [] }
  let(:nomis_checker) do
    double(StaffNomisChecker,
      errors_for: slot_errors,
      prisoner_availability_unknown?: false,
      slot_availability_unknown?: false
    )
  end
  let(:date) { Date.tomorrow }
  let(:slot) do
    ConcreteSlot.new(date.year, date.month, date.day, 14, 0, 15, 30)
  end

  subject do
    described_class.decorate(slot, context: { index: 0, visit: visit })
  end

  before do
    subject.h.output_buffer = ""
    allow(subject).to receive(:nomis_checker).and_return(nomis_checker)
  end

  describe '#slot_picker' do
    let(:form_builder)  do
      ActionView::Helpers::FormBuilder.new(:visit, visit, subject.h, {})
    end

    let(:html_fragment) do
      subject.slot_picker(form_builder)
      Capybara.string(h.output_buffer)
    end

    describe 'prisoner availability' do
      context 'when the api is enabled' do
        context 'with a closed restriction' do
          let(:slot_errors) { [Nomis::Restriction::CLOSED_NAME] }

          it 'renders the checkbox with errors' do
            expect(html_fragment).to have_css('label.date-box__label.date-box--error')
            expect(html_fragment).to have_css('span.date-box__day',    text: date.strftime('%A'))
            expect(html_fragment).to have_css('span.tag--verified',    text: 'Prisoner available')
            expect(html_fragment).to have_css('span.tag--error',       text: 'Closed visit restriction')
            expect(html_fragment).to have_css('input.js-closedRestriction')
            expect(html_fragment).to have_text("#{slot.to_date.strftime('%d %b %Y')} 14:00–15:30")
          end
        end

        context 'when a prisoner is available' do
          it 'renders the checkbox without errors ' do
            expect(html_fragment).to have_css('label.date-box__label')
            expect(html_fragment).to have_css('span.date-box__day',    text: date.strftime('%A'))
            expect(html_fragment).to have_text("#{slot.to_date.strftime('%d %b %Y')} 14:00–15:30")
            expect(html_fragment).not_to have_css("input[disabled='disabled']")
          end
        end

        context 'when a prisoner is not available' do
          context 'with a date in the future' do
            let(:slot_errors) { ['prisoner_banned'] }

            it 'renders the checkbox with errors' do
              expect(html_fragment).to have_css('label.date-box__label.date-box--error')
              expect(html_fragment).to have_css('span.date-box__day',    text: date.strftime('%A'))
              expect(html_fragment).to have_text("#{slot.to_date.strftime('%d %b %Y')} 14:00–15:30")
              expect(html_fragment).to have_css('span.tag--error', text: 'Visits banned')
            end
          end

          context 'when it is a date in the past' do
            let(:date) { Date.yesterday }

            it 'renders the checkbox neither verified or errors' do
              expect(html_fragment).to have_css('label.date-box__label')
              expect(html_fragment).to have_css('span.date-box__day',    text: date.strftime('%A'))
              expect(html_fragment).to have_text("#{slot.to_date.strftime('%d %b %Y')} 14:00–15:30")
              expect(html_fragment).not_to have_css('span.tag--error')
              expect(html_fragment).not_to have_css('span.tag--verified')
            end
          end
        end
      end

      context 'when the api is disabled' do
        before do
          switch_off_api
        end

        it 'renders the checkbox without errors' do
          expect(html_fragment).to have_css('label.date-box__label')
          expect(html_fragment).to have_css('span.date-box__day',    text: date.strftime('%A'))
          expect(html_fragment).to have_text("#{slot.to_date.strftime('%d %b %Y')} 14:00–15:30")
        end
      end
    end

    describe 'slot availability' do
      context 'when the api is enabled' do
        before do
          switch_on :nomis_staff_slot_availability_enabled
          switch_feature_flag_with(:staff_prisons_with_slot_availability, [visit.prison_name])
        end

        context 'when a slot is available' do
          it 'renders the checkbox' do
            expect(html_fragment).to have_css('label.date-box__label')
            expect(html_fragment).to have_css('span.date-box__day',    text: date.strftime('%A'))
            expect(html_fragment).to have_text("#{slot.to_date.strftime('%d %b %Y')} 14:00–15:30")
          end
        end

        context 'when a slot is not available' do
          context 'with a date in the future' do
            let(:slot_errors) { ['slot_not_available'] }

            it 'renders the checkbox' do
              expect(html_fragment).to have_css('label.date-box__label.date-box--error')
              expect(html_fragment).to have_css('span.date-box__day',    text: date.strftime('%A'))
              expect(html_fragment).to have_text("#{slot.to_date.strftime('%d %b %Y')} 14:00–15:30")
              expect(html_fragment).to have_css('span.tag--error', text: 'Fully booked')
            end
          end

          context 'with a date in the past' do
            let(:date) { Date.yesterday }

            it 'renders the checkbox neither verified or errors' do
              expect(html_fragment).to have_css('label.date-box__label.disabled')
              expect(html_fragment).to have_css('span.date-box__day',    text: date.strftime('%A'))
              expect(html_fragment).to have_text("#{slot.to_date.strftime('%d %b %Y')} 14:00–15:30")
              expect(html_fragment).to have_css("input[disabled='disabled']")
              expect(html_fragment).not_to have_css('span.tag--error')
              expect(html_fragment).not_to have_css('span.tag--verified')
            end
          end
        end
      end

      context 'when the api is disabled' do
        before do
          switch_off :nomis_staff_slot_availability_enabled
          switch_feature_flag_with(:staff_prisons_with_slot_availability, [visit.prison_name])
        end

        it 'renders the checkbox without errors' do
          expect(html_fragment).to have_css('label.date-box__label')
          expect(html_fragment).to have_css('span.date-box__day',    text: date.strftime('%A'))
          expect(html_fragment).to have_text("#{slot.to_date.strftime('%d %b %Y')} 14:00–15:30")
        end
      end
    end
  end

  describe '#bookable?' do
    context 'when the prisoner is avaliable' do
      context 'when the slot is not avaliable' do
        before do
          switch_on :nomis_staff_slot_availability_enabled
          switch_feature_flag_with(:staff_prisons_with_slot_availability, [visit.prison_name])
        end

        let(:slot_errors) { ['slot_not_available'] }

        it { expect(subject).not_to be_bookable }
      end

      context 'when the slot is avaliable' do
        before do
          switch_on :nomis_staff_slot_availability_enabled
          switch_feature_flag_with(:staff_prisons_with_slot_availability, [visit.prison_name])
        end

        it { expect(subject).to be_bookable }
      end
    end

    context 'when the prisoner is not avaliable' do
      let(:slot_errors) { ['prisoner_banned'] }

      context 'when the slot is avaliable' do
        before do
          switch_on :nomis_staff_slot_availability_enabled
          switch_feature_flag_with(:staff_prisons_with_slot_availability, [visit.prison_name])
        end

        it { expect(subject).not_to be_bookable }
      end
    end
  end
end
