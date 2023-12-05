class Metrics::RejectionPercentage
  include ActiveModel::Model
  include ActiveModel::Serializers::JSON
  attr_accessor :date

  Rejection::REASONS.each do |reason|
    attr_writer reason

    define_method reason do
      instance_variable_get("@#{reason}") || 0
    end
  end

  def attributes
    Rejection::REASONS.each_with_object(date:) do |reason, obj|
      obj[reason.to_sym] = public_send(reason)
    end
  end
end
