require 'maybe_date'

class VisitorsStep
  include NonPersistedModel

  class Visitor
    include NonPersistedModel
    include Person

    attribute :first_name, String
    attribute :last_name, String
    attribute :date_of_birth, MaybeDate
  end

  attribute :prison, Prison
  attribute :email_address, String
  attribute :phone_no, String
  attribute :override_delivery_error, Boolean
  attribute :delivery_error_type, String
  attribute :delivery_error_occurred, Boolean
  attribute :visitors, Array[Visitor]

  validates :email_address, presence: true
  validates :phone_no, presence: true, length: { minimum: 9 }

  validate :validate_email, :validate_ages

  attr_reader :general # Required in order to assign errors to 'general'

  # Return at least Prison::MAX_VISITORS visitors, filling with new instances
  # as needed. The regular #visitors method will return only those visitors
  # actually supplied via filled fields (or one blank primary visitor).
  def backfilled_visitors
    existing = visitors
    num_needed = Prison::MAX_VISITORS - existing.count
    backfill = num_needed.times.map { Visitor.new }
    existing + backfill
  end

  def visitors_attributes=(params)
    # params is of the form
    # {"0" => {"foo" => "bar"}, "1" => {"foo" => "baz"}}
    # so we sort by key and take the values. We throw away empty visitors.
    pruned = ParameterPruner.new.prune(
      params.sort_by { |k, _| k.to_i }.map(&:last)
    )

    # We always want at least one visitor. Leaving the rest blank is fine, but
    # the first one must both exist and be valid.
    self.visitors = pruned.empty? ? [{}] : pruned.take(Prison::MAX_VISITORS)
  end

  def valid?(*)
    # This must be eager because we want to show errors on all objects.
    visitors.inject([super]) { |a, e| a << e.valid? }.all?
  end

  alias_method :validate, :valid?

  def additional_visitor_count
    visitors.count - 1
  end

private

  def validate_email
    checker = EmailChecker.new(email_address, override_delivery_error)
    unless checker.valid?
      errors.add :email_address, checker.message
      @delivery_error_occurred = checker.delivery_error_occurred?
      @delivery_error_type = checker.error.to_sym
    end
  end

  def validate_ages
    ages = visitors.map(&:age).compact
    prison.validate_visitor_ages_on self, :general, ages
  end
end
