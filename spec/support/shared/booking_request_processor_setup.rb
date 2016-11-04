RSpec.shared_context 'booking response setup' do
  let(:principal_visitor) { visit.principal_visitor }
  let(:visit)             { create :visit_with_three_slots }
  let(:slot_granted)      { visit.slot_option_0 }
  let(:processing_state)  { 'requested' }
  let(:params) do
    {
      slot_option_0:        visit.slot_option_0,
      slot_option_1:        visit.slot_option_1,
      slot_option_2:        visit.slot_option_2,
      slot_granted:         slot_granted,
      prison_id:            visit.prison_id,
      prisoner_id:          visit.prisoner_id,
      principal_visitor_id: visit.principal_visitor.id,
      processing_state:     processing_state,
      visitor_ids:          visit.visitor_ids,
      reference_no:         'A1234BC',
      closed:               [true, false].sample,
      rejection_attributes: {
        allowance_will_renew: '0',
        allowance_renews_on: {
          day: '', month: '', year: ''
        },
        privileged_allowance_expires_on: {
          day: '', month: '', year: ''
        }

      },
      visitors_attributes:  {
        '0' => visit.principal_visitor.attributes.slice('id', 'banned', 'not_on_list')
      }
    }
  end

  let(:user) { create(:user) }
end
