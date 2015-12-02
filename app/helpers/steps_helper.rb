module StepsHelper
  def additional_visitor_selections
    Prison::MAX_VISITORS.times.map { |n| [n.to_s, n] }
  end
end
