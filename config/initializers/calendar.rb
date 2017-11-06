# The BACS non working days match UK bank holidays
Rails.configuration.calendar = Business::Calendar.load_cached('bacs')
