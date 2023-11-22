# The BACS non working days match UK bank holidays
Business::Calendar.load_paths = ['lib/calendars']
Rails.configuration.calendar = Business::Calendar.load_cached('bacs')
