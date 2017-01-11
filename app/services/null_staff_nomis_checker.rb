class NullStaffNomisChecker
  NO_CHECK_REQUIRED = 'no_check_required'.freeze

  def prisoner_existance_status
    NO_CHECK_REQUIRED
  end

  def prisoner_existance_error
    nil
  end

  def prisoner_availability_unknown?
    false
  end

  def errors_for(_slot)
    []
  end

  def prisoner_availability_enabled?
    false
  end
end
