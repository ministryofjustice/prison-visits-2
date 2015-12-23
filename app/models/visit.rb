class Visit < ActiveRecord::Base
  extend FreshnessCalculations

  belongs_to :prison
  belongs_to :prisoner
  has_many :visitors, dependent: :destroy
  has_one :rejection, dependent: :destroy

  validates :prison, :prisoner,
    :contact_email_address, :contact_phone_no, :slot_option_0,
    :processing_state,
    presence: true

  validates :delivery_error_type,
    inclusion: { in: %w[ bounced spam_reported ] },
    allow_nil: true, allow_blank: true

  delegate :email_address, :phone_no, :name, to: :prison, prefix: true
  alias_attribute :first_date, :slot_option_0

  def total_number_of_visitors
    visitors.count
  end

  delegate :reason, to: :rejection, prefix: true
  delegate :privileged_allowance_available?, :privileged_allowance_expires_on,
    :allowance_will_renew?, :allowance_renews_on,
    to: :rejection

  state_machine :processing_state, initial: :requested do
    after_transition on: :accept do |visit|
      visit.send(:set_details_for_metrics, :accepted_at)
    end

    after_transition on: :reject do |visit|
      visit.send(:set_details_for_metrics, :rejected_at)
    end

    after_transition booked: :cancelled do |visit|
      visit.send(:set_details_for_metrics, :cancelled_at)
    end

    after_transition requested: :withdrawn do |visit|
      visit.send(:set_details_for_metrics, :withdrawn_at)
    end

    event :accept do
      transition requested: :booked
    end

    event :reject do
      transition requested: :rejected
    end

    event :cancel do
      transition requested: :withdrawn
      transition withdrawn: :withdrawn
      transition booked: :cancelled
      transition cancelled: :cancelled
    end
  end

  delegate :age, :full_name, :anonymized_name, :number, :date_of_birth,
    to: :prisoner, prefix: true

  delegate :first_name, :last_name, :full_name, :anonymized_name,
    to: :principal_visitor, prefix: :visitor

  alias_method :processable?, :requested?

  def principal_visitor
    visitors.first
  end

  def slots
    [slot_option_0, slot_option_1, slot_option_2].
      select(&:present?).map { |s| ConcreteSlot.parse(s) }
  end

  def slot_granted
    super ? ConcreteSlot.parse(super) : nil
  end

  def date
    slot_granted.begin_at
  end

  def confirm_by
    prison.confirm_by(created_at.to_date)
  end

  def banned_visitors
    visitors.banned
  end

  def unlisted_visitors
    visitors.unlisted
  end

  private

  def set_details_for_metrics(col)
    dt = Time.zone.now
    update_column(col, dt)
    update_column(:days_to_process, (dt.to_date - created_at.to_date).to_f)
  end
end
