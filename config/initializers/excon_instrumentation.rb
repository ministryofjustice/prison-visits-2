ActiveSupport::Notifications.subscribe(/excon/) do |*args|
  ap args
  puts "Excon did stuff!"
end
