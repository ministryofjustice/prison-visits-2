module FreshnessCalculations
  def older_than(date)
    where(arel_table[:created_at].lt(date))
  end

  def only_non_anonymised(field)
    where(arel_table[:field].not_eq('REMOVED'))
  end
end
