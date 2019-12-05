if defined? RSpec
  require 'rspec/core/rake_task'

  task(spec: :environment).clear
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.verbose = false
  end
end
