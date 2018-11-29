task(:stats).prerequisites.unshift task('pvb:statsetup')

namespace :pvb do
  task :statsetup do
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
