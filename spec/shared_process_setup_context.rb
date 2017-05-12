RSpec.shared_context 'process request setup' do
  def sanitize_to_id(value)
    value.to_s.gsub(/\s/, "_").gsub(/[^-\w]/, "").downcase
  end

  def choose_date
    within '.choose-date' do
      find("label[for='visit_slot_granted_#{sanitize_to_id(vst.slots.first.iso8601)}']").click
    end
  end

  let(:contact_email_address) { 'visitor@test.example.com' }
  let(:prison_email_address) { 'prison@test.example.com' }
  let(:prison) {
    create(
      :prison,
      name: 'Reading Gaol',
      email_address: prison_email_address
    )
  }
  let(:vst) {
    create(
      :visit,
      prison: prison,
      contact_email_address: contact_email_address,
      prisoner: create(
        :prisoner,
        number: prisoner_number,
        first_name: 'Oscar',
        last_name: 'Wilde',
        date_of_birth: Date.parse(prisoner_dob)
      )
    )
  }
  let(:prisoner_number) { 'A1459AE' }
  let(:prisoner_dob) { '1976-06-12' }

  let(:sso_response) do
    {
      'uid' => '1234-1234-1234-1234',
      'provider' => 'mojsso',
      'info' => {
        'first_name' => 'Joe',
        'last_name' => 'Goldman',
        'email' => 'joe@example.com',
        'permissions' => [
          { 'organisation' => vst.prison.estate.sso_organisation_name, roles: [] }
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
    visit prison_inbox_path
  end
end
