class StaticPageGenerator
  def self.generate!(pages)
    app = ActionDispatch::Integration::Session.new(Rails.application)

    pages.each do |route, output|
      Rails.logger.info "Generating #{output}..."
      outpath = Rails.root.join('public', output)

      # app.get raises an error if the page cannot be found or generated
      app.get(route)
      File.open(outpath, 'w') do |f|
        f.write(app.response.body)
      end
    end
  end
end
