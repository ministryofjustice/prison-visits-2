# frozen_string_literal: true
module Calendar
  refine Date do
    def holiday?
      Rails.configuration.holidays.include?(self)
    end

    def weekend?
      saturday? || sunday?
    end

    def weekday?
      !weekend?
    end
  end
end
