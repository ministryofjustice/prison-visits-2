json.visit do
  json.id @visit.id
  json.processing_state @visit.processing_state
  json.prison_id @visit.prison.id
  json.confirm_by @visit.confirm_by
  json.contact_email_address @visit.contact_email_address
  json.slots @visit.slots.map(&:iso8601)
  json.slot_granted @visit.slot_granted&.iso8601
end
