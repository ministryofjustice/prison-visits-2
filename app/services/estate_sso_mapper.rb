class EstateSSOMapper
  DIGITAL_ORG = 'digital.noms.moj'.freeze

  def self.grouped_estates
    @grouped_estates ||= begin
      grouped_estates = Hash.new { |h, k| h[k] = [] }
      Estate.where.not(group: nil).each do |estate|
        grouped_estates[estate.group] << estate.sso_organisation_name
      end
      grouped_estates.values.freeze
      grouped_estates.freeze
    end
  end

  def initialize(orgs)
    @orgs = orgs
  end

  def accessible_estates
    return [] if @orgs.empty?

    if admin?
      Estate.all
    else
      Estate.where(sso_organisation_name: accessible_sso_names)
    end
  end

  def admin?
    @orgs.include?(DIGITAL_ORG)
  end

private

  def accessible_sso_names
    @orgs.each_with_object([]) do |org, result|
      if multi_estate?(org)
        estates_for(org).each { |estate| result << estate }
      else
        result << org
      end
    end.uniq
  end

  def multi_estate?(org)
    self.class.grouped_estates.key?(org)
  end

  def estates_for(org)
    self.class.grouped_estates[org]
  end
end
