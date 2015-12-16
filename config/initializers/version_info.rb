Rails.application.config.version_info =
  begin
    JSON.parse(File.read('META'))
  rescue Errno::ENOENT
    {}
  end
