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

  desc 'Create missing users'
  task create_missing_users: :environment do
    require 'csv'
    require 'haikunator'

    # Estates using the same email address:
    #   - APVBU
    #   - Everthorpe
    #   - Isle of Wight
    duplicate_emails =
      Prison.
      joins('INNER JOIN prisons p2
             ON prisons.email_address = p2.email_address
             AND prisons.estate_id <> p2.estate_id').
      pluck(:email_address).
      uniq

    skipped_estates =
      Estate.
      joins(:prisons).
      where(prisons: { enabled: true,
                       email_address: duplicate_emails }).
      pluck('estates.name').
      uniq

    missing_estates =
      Estate.
      joins('LEFT OUTER JOIN users ON users.estate_id = estates.id').
      joins(:prisons).
      where(prisons: { enabled: true }).
      where.not(prisons: { email_address: duplicate_emails }).
      where('users.id IS NULL').
      group('estates.id').
      order('estates.name asc')

    data = CSV.generate(write_headers: true,
                        headers: %i[name email password]) { |csv|
      missing_estates.each do |estate|
        puts "Creating account for #{estate.name}..."
        email = estate.prisons.enabled.first.email_address
        password = Haikunator.haikunate(100)
        User.create!(email: email, password: password, estate: estate)
        csv << { name: estate.name, email: email, password: password }
      end
    }

    STDOUT.puts "CSV:\n"
    STDOUT.puts data

    STDOUT.puts "\nSkipped estates with same email address: #{skipped_estates}"
  end
end
