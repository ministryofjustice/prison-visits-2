require 'uri_template'

class LinkDirectory
  VISIT_STATUS_PATH = '/{locale}/visits/{visit_id}'
  FEEDBACK_PATH = '/{locale}/feedback/new'

  def initialize(prison_finder:, public_service:)
    @prison_finder_template = URITemplate.new(prison_finder)
    @status_template = URITemplate.new(public_service + VISIT_STATUS_PATH)
    @feedback_template = URITemplate.new(public_service + FEEDBACK_PATH)
    @public_service_template = URITemplate.new("#{public_service}/{path}")
  end

  def prison_finder(prison = nil)
    @prison_finder_template.expand(prison: prison ? prison.finder_slug : nil)
  end

  def visit_status(visit, locale: 'en')
    @status_template.expand(visit_id: visit.human_id, locale: locale)
  end

  def feedback_submission(locale: 'en')
    @feedback_template.expand(locale: locale)
  end

  def public_service(path: nil)
    @public_service_template.expand(path: path)
  end
end
