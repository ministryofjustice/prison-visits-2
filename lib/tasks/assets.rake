Rake::Task['assets:precompile'].enhance do
  Rake::Task['assets:generate_static_pages'].invoke
end

namespace :assets do
  desc 'Generates static pages'
  task generate_static_pages: :environment do
    pages = {
      '/pages/404' => '404.html',
      '/pages/500' => '500.html',
      '/pages/503' => '503.html'
    }

    app = ActionDispatch::Integration::Session.new(Rails.application)

    pages.each do |route, output|
      puts "Generating #{output}..."
      outpath = Rails.root.join('public', output)
      resp = app.get(route)
      if resp == 200
        File.open(outpath, 'w') do |f|
          f.write(app.response.body)
        end
      else
        fail "Error generating #{output}"
      end
    end
  end
end
