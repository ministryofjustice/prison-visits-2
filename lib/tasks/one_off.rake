namespace :pvb do
  desc 'Upcase all prisoner numbers'
  task upcase_prisoner_number: :environment do
    max = 1000

    relation = Prisoner.where('number ~ ?', '[a-z]')
    limited_relation = relation.limit(max)

    STDOUT.puts "#{relation.count} records to update."

    updated_count = limited_relation.update_all('number = upper(number)')
    STDOUT.puts "Updated #{updated_count} records"

    while updated_count == max
      sleep(1)
      updated_count = limited_relation.update_all('number = upper(number)')
      STDOUT.puts "Updated #{updated_count} records"
    end
    STDOUT.puts 'Done.'
  end
end
