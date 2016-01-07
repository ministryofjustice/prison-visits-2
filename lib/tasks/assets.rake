Rake::Task['assets:precompile'].enhance do
  Rake::Task['assets:generate_static_pages'].invoke
end

namespace :assets do
  desc 'Generates static pages'
  task generate_static_pages: :environment do
    StaticPageGenerator.generate!(
      '/pages/404' => '404.html',
      '/pages/500' => '500.html',
      '/pages/503' => '503.html'
    )
  end
end
