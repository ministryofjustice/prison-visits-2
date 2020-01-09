if Rails.env.production?
  ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
end
