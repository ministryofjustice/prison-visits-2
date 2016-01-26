json.prison do
  json.id @prison.id
  json.name @prison.name
  json.address @prison.address
  json.postcode @prison.postcode
  json.email_address @prison.email_address
  json.phone_no @prison.phone_no
  json.prison_finder_url link_directory.prison_finder(@prison)
  json._links do
    json.self do
      json.href api_prison_url(@prison, format: :json)
    end
  end
end
