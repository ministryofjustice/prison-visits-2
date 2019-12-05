task(stats: :environment).prerequisites.unshift task('pvb:statsetup': :environment)

namespace :pvb do
  task statsetup: :environment do
    require 'rails/code_statistics'

    ignored = %w[
      ./app/assets
      ./app/views
    ]

    Dir['./app/*'].each do |path|
      next unless File.directory?(path)
      next if ignored.include?(path)
      next if ::STATS_DIRECTORIES.any? { |_, p| p == path }

      name = path.split('/').last.capitalize

      ::STATS_DIRECTORIES << [name, path]
    end
  end
end
