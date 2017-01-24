json.prison do
  json.id @prison.id
  json.name @prison.name
  json.address @prison.address
  json.postcode @prison.postcode
  json.email_address @prison.email_address
  json.phone_no @prison.phone_no
  json.prison_finder_url link_directory.prison_finder(@prison)
  json.max_visitors Prison::MAX_VISITORS
  json.adult_age @prison.adult_age
  json.closed @prison.closed
  json.private @prison.private
  json.enabled @prison.enabled
end
