RSpec.shared_context 'with a process request setup' do
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
      name: 'Leeds',
      email_address: prison_email_address,
      estate: create(:estate, nomis_id: 'LEI')
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
  let(:prisoner_number) { 'G7244GR' }
  let(:prisoner_dob) { '1966-11-22' }

  let(:sso_response) do
    {
      'uid' => '1234-1234-1234-1234',
      'provider' => 'hmpps_sso',
      'info' => {
        'first_name' => 'Joe',
        'last_name' => 'Goldman',
        'user_id' => 485_926,
        'organisations' => [
          vst.prison.estate.nomis_id
        ],
        'roles' => [],
      }
    }
  end

  before do
    OmniAuth.config.add_mock(:hmpps_sso, sso_response)
    visit prison_inbox_path
  end
end
