class EstateSSOMapper
  APVU_ORG = 'apvu.noms.moj'.freeze
  DIGITAL_ORG = 'digital.noms.moj'.freeze

  APVU_ESTATES = %w[
    brinsford.prisons.noms.moj
    bristol.prisons.noms.moj
    drake_hall.prisons.noms.moj
    featherstone.prisons.noms.moj
    hewell.prisons.noms.moj
    stafford.prisons.noms.moj
    stoke_heath.prisons.noms.moj
    swinfen_hall.prisons.noms.moj
    werrington.prisons.noms.moj
    wormwood_scrubs.prisons.noms.moj
  ].freeze

  ISLE_OF_WIGHT_ORG = 'isle_of_wight.noms.moj'.freeze
  ISLE_OF_WIGHT_ESTATES = %w[
    isle_of_wight-albany.prisons.noms.moj
    isle_of_wight-parkhurst.prisons.noms.moj
  ].freeze

  SHEPPEY_CLUSTER_ORG = 'sheppey_cluster.noms.moj'.freeze
  SHEPPEY_CLUSTER_ESTATES = %w[
    elmley.prisons.noms.moj
    standford_hill.prisons.noms.moj
    swaleside.prisons.noms.moj
  ].freeze

  GRENDON_AND_SPRINGHILL_ORG = 'grendon_and_springhill.noms.moj'.freeze
  GRENDON_AND_SPRINGHILL_ESTATES = %w[
    grendon.prisons.noms.moj
    spring_hill.prisons.noms.moj
  ].freeze

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
    [
      GRENDON_AND_SPRINGHILL_ORG,
      SHEPPEY_CLUSTER_ORG,
      ISLE_OF_WIGHT_ORG,
      APVU_ORG
    ].include?(org)
  end

  def estates_for(org)
    case org
    when APVU_ORG then APVU_ESTATES
    when GRENDON_AND_SPRINGHILL_ORG then GRENDON_AND_SPRINGHILL_ESTATES
    when ISLE_OF_WIGHT_ORG then ISLE_OF_WIGHT_ESTATES
    when SHEPPEY_CLUSTER_ORG then SHEPPEY_CLUSTER_ESTATES
    end
  end
end
