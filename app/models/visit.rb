# frozen_string_literal: true
class Visit < ActiveRecord::Base
  extend FreshnessCalculations

  belongs_to :prison
  belongs_to :prisoner
  has_many :visitors, dependent: :destroy
  has_many :visit_state_changes, dependent: :destroy
  has_many :messages
  has_one :rejection, dependent: :destroy
  has_one :cancellation, dependent: :destroy

  validates :prison, :prisoner,
    :contact_email_address, :contact_phone_no, :slot_option_0,
    :processing_state,
    presence: true

  validates :contact_phone_no, phone: true, on: :create

  before_create :sanitise_contact_phone_no

  delegate :address, :email_address, :name, :phone_no, :postcode,
    to: :prison, prefix: true
  alias_attribute :first_date, :slot_option_0

  def total_number_of_visitors
    visitors.count
  end

  delegate :reason, to: :rejection, prefix: true
  delegate :reason, to: :cancellation, prefix: true
  delegate :privileged_allowance_available?, :privileged_allowance_expires_on,
    :allowance_will_renew?, :allowance_renews_on,
    to: :rejection

  scope :from_estate, lambda { |estate|
    joins(prison: :estate).where(estates: { id: estate.id })
  }

  scope :processed, lambda { 
                      joins(<<-EOS).
LEFT OUTER JOIN cancellations ON cancellations.visit_id = visits.id
    EOS
    where(<<-EOS, nomis_cancelled: true).
cancellations.id IS NULL OR cancellations.nomis_cancelled = :nomis_cancelled
    EOS
    without_processing_state(:requested)
  }

  scope :ready_for_processing, lambda { 
                                 joins(<<-EOS).
LEFT OUTER JOIN cancellations ON cancellations.visit_id = visits.id
    EOS
    where(<<-EOS, nomis_cancelled: false).
cancellations.id IS NULL OR cancellations.nomis_cancelled = :nomis_cancelled
    EOS
    with_processing_state(:requested, :cancelled)
  }

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
  end

  def sanitise_contact_phone_no
    self.contact_phone_no = Phonelib.parse(contact_phone_no).sanitized
  end

  def confirm_nomis_cancelled
    Cancellation.
      where(visit_id: id, nomis_cancelled: false).
      update_all(nomis_cancelled: true, updated_at: Time.zone.now)
  end

  def staff_cancellation!(reason)
    cancellation!(reason, nomis_cancelled: true)
    VisitorMailer.cancelled(self).deliver_later
  end

  def visitor_can_cancel_or_withdraw?
    visitor_can_cancel? || can_withdraw?
  end

  def visitor_can_cancel?
    can_cancel? && slot_granted.begin_at >= Time.now.utc
  end

  def visitor_cancel_or_withdraw!
    unless visitor_can_cancel_or_withdraw?
      raise "Can't cancel or withdraw visit #{id}"
    end

    if can_cancel?
      process_cancellation_and_send_email
      return
    end

    withdraw! if can_withdraw?
  end

  delegate :age, :first_name, :last_name, :full_name, :anonymized_name,
    :number, :date_of_birth, to: :prisoner, prefix: true

  delegate :first_name, :last_name, :full_name, :anonymized_name,
    :date_of_birth, to: :principal_visitor, prefix: :visitor

  alias processable? requested?

  def process_cancellation_and_send_email
    cancellation!(Cancellation::VISITOR_CANCELLED, nomis_cancelled: false)
    PrisonMailer.cancelled(self).deliver_later
  end

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
    visitors.loaded? ? visitors.select(&:banned) : visitors.banned
  end

  def unlisted_visitors
    visitors.loaded? ? visitors.select(&:not_on_list) : visitors.unlisted
  end

  def acceptance_message
    messages.
      where.not(visit_state_change_id: nil).
      find_by(
        visit_state_change_id: visit_state_changes.booked.pluck(:id).first
      )
  end

  def rejection_message
    messages.
      where.not(visit_state_change_id: nil).
      find_by(
        visit_state_change_id: visit_state_changes.rejected.pluck(:id).first
      )
  end

  def last_visit_state
    visit_state_changes.order('created_at desc').first
  end

  def additional_visitors
    @additional_visitors ||= visitors.reject { |v| v == principal_visitor }
  end

private

  def cancellation!(reason, nomis_cancelled:)
    transaction do
      cancel!
      Cancellation.create!(visit: self,
                           reason: reason,
                           nomis_cancelled: nomis_cancelled)
    end
  end
end
