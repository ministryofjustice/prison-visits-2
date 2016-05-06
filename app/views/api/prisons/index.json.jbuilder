json.prisons do
  json.array! @prisons do |prison|
    json.id prison.id
    json.name prison.name
    json.prison_url api_prison_url(prison)
  end
end
