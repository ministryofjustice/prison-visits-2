module ContactListMatcherBehaviour
  extend ActiveSupport::Concern

  included do |klass|
    klass.extend ActiveModel::Naming
    klass.send(:define_method, :category) do
      model_name.human
    end
  end

  def initialize
    self.scores_and_contacts = Hash.new { |h, k|  h[k] = [] }
    super
  end

  def add(score, added_contacts)
    scores_and_contacts[score] += Array(added_contacts)
  end

  def contacts
    scores_and_contacts.sort.reverse.map(&:last).reduce(:+) || []
  end

  def contacts_with_data
    @contacts_with_data ||=
      if contacts.empty?
          [no_match]
      else
          contacts.map do |contact|
            [contact, { data: { contact: contact } }]
          end
        end

  end

  def any?
    contacts.any?
  end

private

  attr_accessor :scores_and_contacts
  def no_match
    [
      OpenStruct.new(
        full_name_and_dob: I18n.t('contact_list_matcher_behaviour.none'))
    ]
  end
end
