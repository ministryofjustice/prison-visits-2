require "rails_helper"

RSpec.describe VisitorDecorator do
  let(:visitor) { create(:visitor) }

  subject do
    described_class.decorate(visitor, context: { contact_list: nomis_contacts })
  end

  describe '#contact_list_matching' do
    let(:form_builder) do
      ActionView::Helpers::FormBuilder.new(:visit, subject, subject.h, {})
    end

    let(:html) { Capybara.string(subject.contact_list_matching(form_builder)) }

    context 'with no contacts' do
      let(:nomis_contacts) { [] }

      it 'returns a message that i do not yet have any' do
        expect(html).to have_css('p', text: 'No record of this visitor in NOMIS')
      end
    end

    context 'with contacts' do
      let(:nomis_contacts) do
        build_list(:contact, 4).map do |nomis_contact|
          Nomis::ContactDecorator.decorate(nomis_contact)
        end
      end

      context 'with an exact match' do
        let(:exact_match)    { nomis_contacts.first }

        before do
          visitor.date_of_birth = exact_match.date_of_birth
          visitor.first_name = exact_match.given_name
          visitor.last_name  = exact_match.surname
        end

        it 'shows the visitor has been successfully matched' do
          expect(html).to have_css('.font-xsmall.tag.tag--booked', text: 'Verified')
        end

        it 'has preselected the matched contact' do
          expect(html).to have_select("Match to prisoner's contact list", selected: exact_match.full_name_and_dob)
        end
      end

      context 'with no exact match' do
        it 'does not shows the visitor has been successfully matched' do
          expect(html).not_to have_css('.font-xsmall.tag.tag--booked', text: 'Verified')
        end

        context 'with partially matched contact details' do
          let(:nearest_match) { nomis_contacts.first }

          before do
            visitor.date_of_birth  = nearest_match.date_of_birth
            new_first_name         = nearest_match.given_name.dup
            new_first_name[-1]     = new_first_name[-1].next
            visitor.first_name = new_first_name
            visitor.last_name = nearest_match.surname
          end

          it 'contains the nearest the partially matched contact under the nearest match group', vcr: { cassette_name: 'lookup_active_offender' } do
            expect(html).to have_css('select optgroup[label="Nearest matches"] option', text: nearest_match.full_name_and_dob)
          end
        end

        context 'with no partially matched contact details' do
          it 'has no nearest match' do
            expect(html).to have_css('select optgroup[label="Nearest matches"] option[disabled]', text: 'None')
          end

          it 'has no exact match' do
            expect(html).to have_css('select optgroup[label="Exact matches"] option[disabled]', text: 'None')
          end

          it 'has others' do
            nomis_contacts.each do |nomis_contact|
              expect(html).to have_css('select optgroup[label="Others"] option', text: nomis_contact.full_name_and_dob)
            end
          end
        end
      end
    end
  end

  describe '#exact_match?' do
    let(:nomis_contacts) do
      build_list(:contact, 1).map do |nomis_contact|
        Nomis::ContactDecorator.decorate(nomis_contact)
      end
    end

    let(:contact) { nomis_contacts.first }

    context 'when there is an exact match' do
      before do
        visitor.date_of_birth = contact.date_of_birth
        visitor.first_name = contact.given_name
        visitor.last_name  = contact.surname
      end

      it { expect(subject).to be_exact_match }
    end

    context 'when there is not an exact match' do
      before do
        visitor.date_of_birth = contact.date_of_birth
        visitor.first_name = "#{contact.given_name}bob"
        visitor.last_name  = contact.surname
      end

      it { expect(subject).not_to be_exact_match }
    end
  end

  describe '#banned?' do
    let(:nomis_contacts) do
      [Nomis::ContactDecorator.decorate(contact)]
    end

    before do
      visitor.date_of_birth = contact.date_of_birth
      visitor.first_name = contact.given_name
      visitor.last_name  = contact.surname
    end

    context 'when the visitor is banned' do
      let(:contact) { build(:banned_contact) }

      it { expect(subject).to be_banned }
    end

    context 'when the visitor is not banned' do
      let(:contact) { build(:contact) }

      it { expect(subject).not_to be_banned }
    end
  end
end
