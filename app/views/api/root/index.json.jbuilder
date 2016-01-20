json._links do
  json.prisons do
    json.href api_prisons_url(format: :json)
  end
end
