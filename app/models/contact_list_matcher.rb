require 'jaro_winkler'

class ContactListMatcher
  NEAREST_MATCH_THRESHOLD = 0.90
  EXACT_MATCH_THRESHOLD   = 1

  def initialize(contact_list, visitor)
    self.contact_list = contact_list
    self.visitor      = visitor
    match!
  end

  def matches
    [exact_matches, nearest_matches, others]
  end

  def exact_matches
    @exact_matches ||= ContactListMatcher::ExactMatches.new
  end

  def any?
    matches.any?(&:any?)
  end

private

  attr_accessor :requested_contacts, :contact_list, :visitor

  def nearest_matches
    @nearest_matches ||= ContactListMatcher::NearestMatches.new
  end

  def others
    @others ||= ContactListMatcher::Others.new
  end

  def match!
    contact_list.each do |contact|
      if match_date_of_birth?(contact)
        score, bucket = matched_bucket_for(contact)
        bucket.add(score, contact)
      else
        others.add(0, contact)
      end
    end
  end

  def match_date_of_birth?(contact)
    return false if contact.date_of_birth.blank?

    visitor.date_of_birth.to_date == contact.date_of_birth.to_date
  end

  def matched_bucket_for(candidate)
    score = JaroWinkler.distance(visitor_full_name, candidate.full_name)
    bucket = case
             when score == 1
               exact_matches
             when score.between?(NEAREST_MATCH_THRESHOLD, EXACT_MATCH_THRESHOLD)
               nearest_matches
             else
               others
             end
    [score, bucket]
  end

  def visitor_full_name
    visitor.full_name.downcase.squish
  end
end
