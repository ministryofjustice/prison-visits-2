class Visit < ApplicationRecord
  extend FreshnessCalculations
  include PrincipalVisitor

  belongs_to :prison
  belongs_to :prisoner
  has_many :visitors, dependent: :destroy

  has_many :visit_state_changes, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_one :rejection, dependent: :destroy, inverse_of: :visit
  has_one :cancellation, dependent: :destroy

  validates :prison,
    :prisoner,
    :contact_email_address,
    :contact_phone_no,
    :slot_option_0,
    :processing_state,
    presence: true

  validates :contact_phone_no, phone: true, on: :create

  before_create :sanitise_contact_phone_no

  delegate :address, :email_address, :name, :phone_no, :postcode,
    to: :prison, prefix: true
  alias_attribute :first_date, :slot_option_0

  delegate :reasons, to: :rejection, prefix: true
  delegate :reasons, to: :cancellation, prefix: true
  delegate :allowance_will_renew?, :allowance_renews_on,
    to: :rejection

  scope :from_estates, lambda { |estates|
    joins(prison: :estate).where(estates: { id: estates.map(&:id) })
  }

  scope :processed, lambda {
    joins(<<~JOIN).
      LEFT OUTER JOIN cancellations ON cancellations.visit_id = visits.id
    JOIN
      where(<<~WHERE, nomis_cancelled: true).
        cancellations.id IS NULL OR cancellations.nomis_cancelled = :nomis_cancelled
    WHERE
      without_processing_state(:requested)
  }

  scope :ready_for_processing, lambda {
    joins(<<~JOIN).
      LEFT OUTER JOIN cancellations ON cancellations.visit_id = visits.id
    JOIN
      where(<<~WHERE, nomis_cancelled: false).
        cancellations.id IS NULL OR cancellations.nomis_cancelled = :nomis_cancelled
    WHERE
      with_processing_state(:requested, :cancelled)
  }

  accepts_nested_attributes_for :messages, :rejection, reject_if: :all_blank
  accepts_nested_attributes_for :visitors, update_only: true
  accepts_nested_attributes_for :prisoner, update_only: true
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
      transition booked: :cancelled
    end

    event :withdraw do
      transition requested: :withdrawn
    end

    state :rejected do
      validates :rejection, presence: true
    end
  end

  def total_number_of_visitors
    visitors.count
  end

  def sanitise_contact_phone_no
    self.contact_phone_no = Phonelib.parse(contact_phone_no).sanitized
  end

  def allowed_visitors
    visitors.reject { |v| not_allowed_visitor_ids.include?(v.id) }
  end

  def banned_visitors
    visitors.select(&:banned?)
  end

  def unlisted_visitors
    visitors.select(&:not_on_list?)
  end

  def visitors_rejected_for_other_reasons
    visitors.select(&:other_rejection_reason?)
  end

  def confirm_nomis_cancelled
    Cancellation.
      where(visit_id: id, nomis_cancelled: false).
      update_all(nomis_cancelled: true, updated_at: Time.zone.now)
  end

  delegate :age, :first_name, :last_name, :full_name, :anonymized_name,
    :number, :date_of_birth, to: :prisoner, prefix: true

  delegate :first_name, :last_name, :full_name, :anonymized_name,
    :date_of_birth, to: :principal_visitor, prefix: :visitor

  alias_method :processable?, :requested?

  def slots
    [slot_option_0, slot_option_1, slot_option_2].
      select(&:present?).map { |s| ConcreteSlot.parse(s) }
  end

  def slot_granted
    super.present? ? ConcreteSlot.parse(super) : nil
  end

  def date
    slot_granted.begin_at
  end

  def confirm_by
    prison.confirm_by(created_at.to_date)
  end

  def acceptance_message
    messages.
      where.not(visit_state_change_id: nil).
      find_by(
        visit_state_change_id: visit_state_changes.booked.pluck(:id).first)
  end

  def rejection_message
    messages.
      where.not(visit_state_change_id: nil).
      find_by(
        visit_state_change_id: visit_state_changes.rejected.pluck(:id).first)
  end

  def last_visit_state
    visit_state_changes.order('created_at desc').first
  end

  def additional_visitors
    @additional_visitors ||= visitors.reject { |v| v == principal_visitor }
  end

  def allowed_additional_visitors
    additional_visitors.select(&:allowed?)
  end

private

  def not_allowed_visitor_ids
    @not_allowed_visitor_ids ||=
      unlisted_visitors.map(&:id) +
      banned_visitors.map(&:id) +
      visitors_rejected_for_other_reasons.map(&:id)
  end
end
