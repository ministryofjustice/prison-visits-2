require 'rails_helper'

RSpec.describe LoadTestDataRemover do
  let(:contact_email_address) { 'visitor@test.example.com' }
  let(:prison_email_address) { 'prison@test.example.com' }
  let(:prison) {
    create(
      :prison,
      name: 'Leeds',
      email_address: prison_email_address,
      estate: create(:estate, nomis_id: 'LEI')
    )
  }
  let(:prisoner) {
    create(
      :prisoner,
      number: prisoner_number,
      first_name: 'Load',
      last_name: 'Test',
      date_of_birth: Date.parse(prisoner_dob)
    )
  }

  let(:vst) {
    create(
      :visit,
      prison: prison,
      contact_email_address: contact_email_address,
      prisoner: prisoner
    )
  }
  let(:prisoner_number) { 'A1475AE' }
  let(:prisoner_dob) { '1979-04-23' }
  let(:visitor) { vst.visitors.last }

  context 'when visit requests are generated by load tests' do
    let(:first_name) { 'Load' }
    let(:last_name)  { 'Test' }

    context 'with "remove_load_test_data" flag switched on' do
      it 'removes them' do
        remove_load_test_data(:on)
        visitor.update!(first_name: first_name, last_name: last_name)

        expect { described_class.run }.
          to change(Visit, :count).
            from(1).
            to(0).
          and change(Prisoner, :count).
            from(1).
            to(0)
      end
    end
  end

  context 'when visit request not generated by load tests' do
    let(:first_name) { 'Load' }
    let(:last_name)  { 'Spencer' }
    let(:visitor)    { vst.visitors.last }

    context 'with "remove_load_test_data" flag switched off' do
      it 'does not remove them' do
        remove_load_test_data(:off)
        # visitor.update!(first_name: first_name, last_name: last_name)

        expect { described_class.run }.
          not_to change { [Visit.count, Prisoner.count] }
      end
    end

    context "with 'remove_load_test_data' flag switched on" do
      context "when visitor is not 'Load Test'" do
        it 'does not remove them' do
          remove_load_test_data(:on)
          # visitor.update!(first_name: first_name, last_name: last_name)

          expect { described_class.run }.
            not_to change { [Visit.count, Prisoner.count] }
        end
      end
    end
  end

  def visit_for(first_name, last_name)
    Visit.joins(:visitors).where("visitors.first_name = '#{first_name}'", "visitors.last_name = '#{last_name}'")
  end

  def remove_load_test_data(value)
    if value == :on
      Rails.configuration.remove_load_test_data = true
    else
      Rails.configuration.remove_load_test_data = false
    end
  end
end
