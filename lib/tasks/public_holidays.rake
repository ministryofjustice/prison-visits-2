require 'open-uri'

task :update_holidays => :environment do
  hash = JSON.parse(open('https://www.gov.uk/bank-holidays.json').read)

  events = hash.
    fetch('england-and-wales').
    fetch('events').
    map { |event| [Date.parse(event.fetch('date')), event.fetch('title')] }.
    select { |date, _| date.year >= Time.zone.today.year }

  File.open('config/initializers/holidays.rb', 'w') do |f|
    f.puts 'Rails.application.config.holidays = ['

    while events.any?
      date, title = events.shift
      f.print '  Date.new(%4d, %2d, %2d)' % [date.year, date.month, date.mday]
      f.print events.any? ? ',' : ' '
      f.puts " # #{title}"
    end

    f.puts ']'
  end
end
