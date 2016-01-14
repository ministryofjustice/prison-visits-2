require 'uri_template'

class LinkDirectory
  GOOGLE_MAPS = 'http://google.com/maps?q={query}'
  RATE_SERVICE = 'http://www.gov.uk/done/prison-visits'

  def initialize(prison_finder:)
    @prison_finder_template = URITemplate.new(prison_finder)
  end

  def prison_finder(prison = nil)
    @prison_finder_template.expand(prison: prison ? prison.finder_slug : nil)
  end

  def google_maps(query)
    URITemplate.new(GOOGLE_MAPS).expand(query: query)
  end

  def rate_service
    RATE_SERVICE
  end
end
