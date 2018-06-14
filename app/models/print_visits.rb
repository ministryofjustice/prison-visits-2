class PrintVisits
  include MemoryModel

  attribute :visit_date, :accessible_date

  validate :check_date

  def check_date
    today = Time.zone.today
    six_months_ago = 6.months.ago.to_date
    date_to_check = visit_date.to_date

    unless date_to_check.between?(six_months_ago, today)
      errors.add(
        :base,
        I18n.t('search_date_invalid_html',
          scope: %i[print_visits errors]))
    end
  end
end
