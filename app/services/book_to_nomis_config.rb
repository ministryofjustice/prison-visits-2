class BookToNomisConfig
  def initialize(staff_nomis_checker, prison_name, opted_in)
    self.staff_nomis_checker = staff_nomis_checker
    self.prison_name = prison_name
    self.opted_in = opted_in
  end

  def possible_to_book?
    Nomis::Feature.book_to_nomis_enabled?(prison_name) &&
      prisoner_existance_valid? &&
      prisoner_availability_working? &&
      slot_availability_working? &&
      contact_list_working?
  end

  def opted_in?
    return false unless possible_to_book?

    opted_in.nil? || opted_in
  end

private

  attr_accessor :staff_nomis_checker, :prison_name
  attr_reader :opted_in

  def opted_in=(val)
    # TODO: Changes in Rails 5 to `ActiveRecord::Type::Boolean.new.cast(string)`
    @opted_in = ActiveRecord::Type::Boolean.new.type_cast_from_database(val)
  end

  def prisoner_existance_valid?
    staff_nomis_checker.prisoner_existance_status == StaffNomisChecker::VALID
  end

  def prisoner_availability_working?
    Nomis::Feature.prisoner_availability_enabled? &&
      !staff_nomis_checker.prisoner_availability_unknown?
  end

  def slot_availability_working?
    Nomis::Feature.slot_availability_enabled?(prison_name) &&
      !staff_nomis_checker.slot_availability_unknown?
  end

  def contact_list_working?
    Nomis::Feature.contact_list_enabled?(prison_name) &&
      !staff_nomis_checker.contact_list_unknown?
  end
end
