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

  desc 'Create user'
  task create_user: :environment do
    require 'highline'
    cli = HighLine.new

    estate_name = cli.ask('Estate name: ')
    estate = Estate.find_by!(name: estate_name)

    email_address = cli.ask('Email address: ')

    password = cli.ask('Password             : ') { |q| q.echo = 'x' }
    password_confirmation = cli.ask('Password confirmation: ') { |q|
      q.echo = 'x'
    }

    if password != password_confirmation
      cli.say("Passwords don't match!")
      exit
    end

    user = User.new
    user.email = email_address
    user.password = password
    user.estate = estate
    user.save!

    cli.say("User created for #{estate.name}")
  end
end
