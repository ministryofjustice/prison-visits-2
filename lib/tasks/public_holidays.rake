require 'open-uri'

task :update_holidays do
  hash = JSON.parse(open('https://www.gov.uk/bank-holidays.json').read)
  File.open('config/initializers/holidays.rb', 'w') do |f|
    f.puts 'Rails.application.config.holidays = ['
    f.puts hash.fetch('england-and-wales').fetch('events').map { |event|
      date = Date.parse(event.fetch('date'))
      "  Date.new(#{date.year}, #{date.month}, #{date.mday})"
    }.join(",\n")
    f.puts ']'
  end
end
