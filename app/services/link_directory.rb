class LinkDirectory
  def initialize(prison_finder:)
    @prison_finder_base = prison_finder
  end

  def prison_finder(prison = nil)
    slug = prison ? prison.finder_slug : nil
    [@prison_finder_base, slug].compact.join('/')
  end
end
