module FreshnessCalculations
  def older_than(date)
    where(arel_table[:created_at].lt(date))
  end

  def only_non_anon_name
    where(arel_table[:first_name].not_eq('REMOVED'))
  end

  def only_non_anon_email
    where(arel_table[:contact_email_address].not_eq('REMOVED'))
  end
end
