class NomisInfo
  PRISONER_INFO_VALID   = 'prisoner_info_valid'.freeze
  PRISONER_INFO_INVALID = 'prisoner_info_invalid'.freeze

  def initialize(prisoner_validation, location_validation)
    self.prisoner_validation = prisoner_validation
    self.location_validation = location_validation
  end

  def notice
    prisoner_details_validation || prisoner_location_validation
  end

private

  attr_accessor :prisoner_validation, :location_validation

  def prisoner_details_validation
    unless prisoner_validation.valid?
      prisoner_validation.errors.full_messages.first
    end
  end

  def prisoner_location_validation
    unless location_validation.valid?
      location_validation.errors.full_messages.first
    end
  end
end
