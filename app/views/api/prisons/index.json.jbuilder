json.prisons do
  json.array! @prisons do |prison|
    json.id prison.id
    json.name prison.name
    json._links do
      json.self do
        json.href api_prison_url(prison, format: :json)
      end
    end
  end
end

json._links do
  json.self do
    json.href api_prisons_url(format: :json)
  end
end
