class Depersonalizer
  STRING = 'REMOVED'
  DATE = Date.new(1, 1, 1)

  def remove_personal_information(cutoff_date)
    Prisoner.older_than(cutoff_date).only_non_anon_name.update_all \
      first_name: STRING, last_name: STRING,
      number: STRING, date_of_birth: DATE

    Visitor.older_than(cutoff_date).only_non_anon_name.update_all \
      first_name: STRING, last_name: STRING, date_of_birth: DATE

    Visit.older_than(cutoff_date).only_non_anon_email.update_all \
      contact_email_address: STRING, contact_phone_no: STRING
  end
end
