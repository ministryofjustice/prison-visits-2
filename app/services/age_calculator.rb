class AgeCalculator
  # See https://stackoverflow.com/a/2357790

  def age(date_of_birth, today = Time.zone.today)
    adjustment = had_birthday_this_year?(date_of_birth, today) ? 0 : 1
    today.year - date_of_birth.year - adjustment
  end

private

  def had_birthday_this_year?(date_of_birth, today)
    today.month > date_of_birth.month ||
      (today.month == date_of_birth.month && today.day >= date_of_birth.day)
  end
end
