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

  subject do
    described_class.decorate(
      slot,
      context: {
        visit: visit,
        nomis_checker: nomis_checker,
        index: 0
      }
    )
  end

  before do
    subject.h.output_buffer = ""
  end

  describe '#slot_picker' do
    let(:form_builder)  do
      ActionView::Helpers::FormBuilder.new(:visit, visit, subject.h, {})
    end
    let(:date) { Date.tomorrow }
    let(:slot) do
      ConcreteSlot.new(date.year, date.month, date.day, 14, 0, 15, 30)
    end
    let(:html_fragment) do
      subject.slot_picker(form_builder)
      Capybara.string(h.output_buffer)
    end

    describe 'prisoner availability' do
      context 'when a prisoner is available' do
        it 'renders the checkbox without errors ' do
          expect(html_fragment).to have_css('label.date-box__label')
          expect(html_fragment).to have_css('span.date-box__number', text: '1')
          expect(html_fragment).to have_css('span.date-box__day',    text: date.strftime('%A'))
          expect(html_fragment).to have_text("#{slot.to_date.strftime('%e %B %Y')} 14:00–15:30")
          expect(html_fragment).not_to have_css("input[disabled='disabled']")
        end
      end

      context 'when a prisoner is not available' do
        context 'with a date in the future' do
          let(:slot_errors) { ['prisoner_banned'] }

          it 'renders the checkbox with errors' do
            expect(html_fragment).to have_css('label.date-box__label.date-box--error')
            expect(html_fragment).to have_css('span.date-box__number', text: '1')
            expect(html_fragment).to have_css('span.date-box__day',    text: date.strftime('%A'))
            expect(html_fragment).to have_text("#{slot.to_date.strftime('%e %B %Y')} 14:00–15:30")
            expect(html_fragment).to have_css('span.tag--error', text: 'Visits banned')
          end
        end

        context 'for a date in the past' do
          let(:date) { Date.yesterday }

          it 'renders the checkbox neither verified or errors' do
            expect(html_fragment).to have_css('label.date-box__label')
            expect(html_fragment).to have_css('span.date-box__number', text: '1')
            expect(html_fragment).to have_css('span.date-box__day',    text: date.strftime('%A'))
            expect(html_fragment).to have_text("#{slot.to_date.strftime('%e %B %Y')} 14:00–15:30")
            expect(html_fragment).not_to have_css('span.tag--error')
            expect(html_fragment).not_to have_css('span.tag--verified')
          end
        end
      end

      context 'when the api is disabled' do
        before do
          switch_on :nomis_staff_prisoner_availability_enabled
        end

        it 'renders the checkbox without errors' do
          expect(html_fragment).to have_css('label.date-box__label')
          expect(html_fragment).to have_css('span.date-box__number', text: '1')
          expect(html_fragment).to have_css('span.date-box__day',    text: date.strftime('%A'))
          expect(html_fragment).to have_text("#{slot.to_date.strftime('%e %B %Y')} 14:00–15:30")
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
            expect(html_fragment).to have_css('span.date-box__number', text: '1')
            expect(html_fragment).to have_css('span.date-box__day',    text: date.strftime('%A'))
            expect(html_fragment).to have_text("#{slot.to_date.strftime('%e %B %Y')} 14:00–15:30")
          end
        end

        context 'when a slot is not available' do
          context 'with a date in the future' do
            let(:slot_errors) { ['slot_not_available'] }

            it 'renders the checkbox' do
              expect(html_fragment).to have_css('label.date-box__label.date-box--error')
              expect(html_fragment).to have_css('span.date-box__number', text: '1')
              expect(html_fragment).to have_css('span.date-box__day',    text: date.strftime('%A'))
              expect(html_fragment).to have_text("#{slot.to_date.strftime('%e %B %Y')} 14:00–15:30")
              expect(html_fragment).to have_css('span.tag--error', text: 'Fully booked')
            end
          end

          context 'wiht a date in the past' do
            let(:date) { Date.yesterday }

            it 'renders the checkbox neither verified or errors' do
              expect(html_fragment).to have_css('label.date-box__label.disabled')
              expect(html_fragment).to have_css('span.date-box__number', text: '1')
              expect(html_fragment).to have_css('span.date-box__day',    text: date.strftime('%A'))
              expect(html_fragment).to have_text("#{slot.to_date.strftime('%e %B %Y')} 14:00–15:30")
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
          expect(html_fragment).to have_css('span.date-box__number', text: '1')
          expect(html_fragment).to have_css('span.date-box__day',    text: date.strftime('%A'))
          expect(html_fragment).to have_text("#{slot.to_date.strftime('%e %B %Y')} 14:00–15:30")
        end
      end
    end
  end
end
