json.prisons do
  json.array! @prisons do |prison|
    json.id         prison.id
    json.name       prison.name
    json.closed     prison.closed
    json.private    prison.private
    json.prison_url api_prison_url(prison)
  end
end
