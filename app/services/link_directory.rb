require 'uri_template'

class LinkDirectory
  def initialize(prison_finder:)
    @prison_finder_template = URITemplate.new(prison_finder)
  end

  def prison_finder(prison = nil)
    @prison_finder_template.expand(prison: prison ? prison.finder_slug : nil)
  end
end
