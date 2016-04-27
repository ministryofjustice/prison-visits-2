class Visit < ActiveRecord::Base
  extend FreshnessCalculations

  belongs_to :prison
  belongs_to :prisoner
  has_many :visitors, dependent: :destroy
  has_many :visit_state_changes, dependent: :destroy
  has_one :rejection, dependent: :destroy

  validates :prison, :prisoner,
    :contact_email_address, :contact_phone_no, :slot_option_0,
    :processing_state,
    presence: true

  delegate :address, :email_address, :name, :phone_no, :postcode,
    to: :prison, prefix: true
  alias_attribute :first_date, :slot_option_0

  def total_number_of_visitors
    visitors.count
  end

  delegate :reason, to: :rejection, prefix: true
  delegate :privileged_allowance_available?, :privileged_allowance_expires_on,
    :allowance_will_renew?, :allowance_renews_on,
    to: :rejection

  state_machine :processing_state, initial: :requested do
    after_transition do |visit|
      visit.visit_state_changes <<
        VisitStateChange.new(visit_state: visit.processing_state)
    end

    event :accept do
      transition requested: :booked
    end

    event :reject do
      transition requested: :rejected
    end

    event :cancel do
      transition requested: :withdrawn
      transition booked: :cancelled
      transition rejected: :rejected
    end

    after_transition booked: :cancelled do |visit, _|
      PrisonMailer.cancelled(visit).deliver_later
    end
  end

  delegate :age, :first_name, :last_name, :full_name, :anonymized_name,
    :number, :date_of_birth, to: :prisoner, prefix: true

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
end
