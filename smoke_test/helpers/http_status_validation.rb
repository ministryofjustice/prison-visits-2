module HttpStatusValidation
module_function

  def validate_response_status!
    if (400..599).include?(page.status_code)
      puts "Failed: bad status #{page.status_code} for #{page.current_path}"
      fail
    end
  end

  private_class_method :validate_response_status!
end
