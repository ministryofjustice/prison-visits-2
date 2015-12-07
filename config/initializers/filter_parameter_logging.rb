Rails.application.config.filter_parameters += [
  :password,

  # Fields for visitor
  :visitor_first_name,
  :visitor_last_name,
  :visitor_date_of_birth,
  :contact_email_address,
  :contact_phone_no,

  # Fields for the additional visitor
  :first_name,
  :last_name,
  :date_of_birth,

  # Fields for prisoner
  :prisoner_first_name,
  :prisoner_last_name,
  :prisoner_date_of_birth,
  :prisoner_number,

  # Fields for Visitors Step
  :email_address,
  :phone_no
]
