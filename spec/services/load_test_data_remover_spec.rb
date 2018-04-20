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
  let!(:visit) {
    create(
      :visit,
      prison: prison,
      contact_email_address: contact_email_address,
      prisoner: create(
        :prisoner,
        number: prisoner_number,
        first_name: 'Load',
        last_name: 'Test',
        date_of_birth: Date.parse(prisoner_dob)
      )
    )
  }
  let(:prisoner_number) { 'A1475AE' }
  let(:prisoner_dob) { '1979-04-23' }
  let(:visitor)    { visit.visitors.last }

  def visit_for(first_name, last_name)
    Visit.joins(:visitors).where("visitors.first_name = '#{first_name}'", "visitors.last_name = '#{last_name}'")
  end

  context 'visit requests generated by load tests' do
    let(:first_name) { 'Load' }
    let(:last_name)  { 'Test' }

    it 'removes them' do
      visitor.update!(first_name: first_name, last_name: last_name)
      expect(visit_for(first_name, last_name)).to exist
      subject.run
      expect(visit_for(first_name, last_name)).not_to exist
    end
  end

  context 'visit request not generated by load tests' do
    let(:first_name) { 'Load' }
    let(:last_name)  { 'Spencer' }
    let(:visitor)    { visit.visitors.last }

    it 'does not remove them' do
      visitor.update!(first_name: first_name, last_name: last_name)
      expect(visit_for(first_name, last_name)).to exist
      subject.run
      expect(visit_for(first_name, last_name)).to exist
    end
  end
end
