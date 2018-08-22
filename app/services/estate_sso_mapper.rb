class EstateSSOMapper
  DIGITAL_ORG = 'digital.noms.moj'.freeze

  # Can't use a hash with a default value of an empty array because we want to
  # freeze it. A frozen hash with default values can't read unknown values or it
  # raises a frozen error.
  def self.grouped_estates
    @grouped_estates ||= begin
      grouped_estates = Estate.all.each_with_object({}) do |estate, result|
        estate.admins.each do |admin|
          result[admin] ||= []
          result[admin] << estate.sso_organisation_name
        end
      end
      grouped_estates.values.each(&:freeze)
      grouped_estates.freeze
    end
  end

  def self.reset_grouped_estates
    @grouped_estates = nil
  end

  def initialize(user_sso_orgs)
    self.user_sso_orgs = user_sso_orgs
  end

  def accessible_estates
    return [] if user_sso_orgs.empty?
    if admin?
      Estate.all
    else
      Estate.where(sso_organisation_name: accessible_sso_names)
    end
  end

  def admin?
    user_sso_orgs.include?(DIGITAL_ORG)
  end

private

  attr_accessor :user_sso_orgs

  def accessible_sso_names
    user_sso_orgs.each_with_object([]) do |org, result|
      estates_for(org).each { |estate| result << estate }
    end.uniq
  end

  def estates_for(org)
    self.class.grouped_estates[org] || []
  end
end
