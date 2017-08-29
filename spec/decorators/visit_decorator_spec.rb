require 'rails_helper'

RSpec.describe VisitDecorator do
  let(:visit) { create(:visit) }
  let(:checker) { instance_double(StaffNomisChecker) }

  subject do
    described_class.decorate(visit, context: { staff_nomis_checker: checker })
  end

  describe '#slots'do
    it 'are decorated object' do
      expect(subject.slots).to all(be_decorated)
    end
  end

  describe '#nomis_offender_id' do
    context 'when the Nomis::Api is enabled' do
      let(:offender) { double(Nomis::Offender, id: 1234) }

      before do
        expect(checker).to receive(:offender).and_return(offender)
      end

      it 'returns the offender id' do
        expect(subject.nomis_offender_id).to eq(offender.id)
      end
    end

    context 'when the Nomis::Api is disabled' do
      before do
        switch_off_api
      end
      it 'does not call the API' do
        expect(checker).not_to receive(:offender)
        subject.nomis_offender_id
      end
    end
  end

  describe '#processed_at' do
    context 'when requested' do
      let(:visit) { create(:visit, :requested) }

      it 'returns the visit creation time' do
        expect(subject.processed_at).to eq(visit.created_at)
      end
    end

    context 'when not requested' do
      let!(:last_state_change) do
        VisitStateChange.create!(visit: visit,
                                 visit_state: 'cancelled',
                                 created_at: 1.day.from_now)
      end

      it 'returns the last visit state change creation time' do
        expect(subject.processed_at).to eq(last_state_change.reload.created_at)
      end
    end
  end

  describe '#contact_list' do
    let(:visitor) { build(:visitor) }
    let(:form_builder)  do
      ActionView::Helpers::FormBuilder.new(:visit, visitor, subject.h, {})
    end

    let(:selected)     { contacts.last }
    let(:offender)     { Nomis::Offender.new(id: 'some_id', noms_id: 'noms_id') }
    let(:html)         { Capybara.string(subject.contact_list(form_builder, selected&.id)) }

    context 'with contacts' do
      let(:contacts) { build_list(:contact, 4) }

      before do
        expect(checker).to receive(:approved_contacts).twice.and_return(contacts)
      end

      it 'return the contact list dropdown' do
        Nomis::ContactDecorator.decorate_collection(contacts).each do |contact|
          if contact.id == selected.id
            expect(html).to have_xpath("//select/option[@value='#{contact.id}'][@data-contact='#{contact.to_data_attributes.to_json}'][@selected]", text: contact.full_name_and_dob)
          else
            expect(html).to have_xpath("//option[@value='#{contact.id}'][@data-contact='#{contact.to_data_attributes.to_json}']", text: contact.full_name_and_dob)
          end
        end
      end
    end

    context 'without contact' do
      let(:contacts) { [] }

      before do
        expect(checker).to receive(:approved_contacts).and_return(contacts)
      end

      it 'returns a message that i do not yet have' do
        expect(html).to have_css('p', text: 'No record of this visitor in NOMIS')
      end
    end
  end
end
