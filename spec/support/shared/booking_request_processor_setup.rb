RSpec.shared_context 'staff response setup' do
  let(:lead_visitor)     { visit.lead_visitor }
  let(:principal_visitor) { visit.principal_visitor }
  let(:visit)             { create :visit_with_three_slots }
  let(:slot_granted)      { visit.slot_option_0 }
  let(:processing_state)  { 'requested' }
  let(:visitor_fields)    { %w[id not_on_list banned] }
  let(:params) do
    {
      slot_option_0:        visit.slot_option_0,
      slot_option_1:        visit.slot_option_1,
      slot_option_2:        visit.slot_option_2,
      slot_granted:         slot_granted,
      prison_id:            visit.prison_id,
      prisoner_id:          visit.prisoner_id,
      processing_state:     processing_state,
      visitor_ids:          visit.visitor_ids,
      reference_no:         'A1234BC',
      closed:               [true, false].sample,
      rejection_attributes: {
        allowance_renews_on: {
          day: '', month: '', year: ''
        }
      },
      visitors_attributes:  {
        '0' => lead_visitor.attributes.slice(*visitor_fields).
          merge('banned_until' => principal_visitor.banned_until.to_s)
      }
    }
  end

  let(:user) { create(:user) }
  let(:validate_visitors_nomis_ready) { nil }
end
