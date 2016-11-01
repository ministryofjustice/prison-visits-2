# frozen_string_literal: true
module MetricsHelper
  SECONDS_PER_DAY = 24 * 60 * 60

  def image_for_performance_score(score)
    case score
    when 0..(3 * SECONDS_PER_DAY)
      image_tag('icons/green-dot.png')
    when (3 * SECONDS_PER_DAY + 1)..(4 * SECONDS_PER_DAY)
      image_tag('icons/amber-dot.png')
    else
      image_tag('icons/red-dot.png')
    end
  end
end
