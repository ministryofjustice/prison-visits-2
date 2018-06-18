class BookToNomisConfig
  def initialize(staff_nomis_checker,
    prison_name, opted_in,
    already_booked_in_nomis,
    prisoner_details_presenter)
    self.staff_nomis_checker        = staff_nomis_checker
    self.prison_name                = prison_name
    self.opted_in                   = opted_in
    self.already_booked_in_nomis    = already_booked_in_nomis
    self.prisoner_details_presenter = prisoner_details_presenter
  end

  def possible_to_book?
    Nomis::Feature.book_to_nomis_enabled?(prison_name) &&
      slot_availability_working? &&
      prisoner_checks_working? &&
      !already_booked_in_nomis?
  end

  def opted_in?
    return false unless possible_to_book?

    opted_in.nil? || opted_in
  end

  def already_booked_in_nomis?
    @already_booked_in_nomis
  end

private

  attr_accessor :staff_nomis_checker,
    :prison_name,
    :already_booked_in_nomis,
    :prisoner_details_presenter

  attr_reader :opted_in

  def opted_in=(val)
    @opted_in = ActiveRecord::Type::Boolean.new.cast(val)
  end

  def prisoner_existance_valid?
    prisoner_details_presenter.
      prisoner_existance_status == PrisonerDetailsPresenter::VALID
  end

  def prisoner_availability_working?
    !staff_nomis_checker.prisoner_availability_unknown?
  end

  def slot_availability_working?
    Nomis::Feature.slot_availability_enabled?(prison_name) &&
      !staff_nomis_checker.slot_availability_unknown?
  end

  def contact_list_working?
    !staff_nomis_checker.contact_list_unknown?
  end

  def offender_restrictions_working?
    Nomis::Feature.restrictions_enabled? &&
      !staff_nomis_checker.prisoner_restrictions_unknown?
  end

  def prisoner_checks_working?
    prisoner_existance_valid? &&
    prisoner_availability_working? &&
    contact_list_working? &&
    offender_restrictions_working?
  end
end
