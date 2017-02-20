class HumanReadableId
  MAX_NUMBER = Base32::Crockford.decode('ZZZZZZZZ') # Largest 8 digit number

  def self.update_unique_id(klass, primary_key, column)
    ActiveRecord::Base.transaction(requires_new: true) do
      generate_id do |candidate_id|
        klass.
          where(id: primary_key, column => nil).
          update_all(column => candidate_id)
        candidate_id
      end
    end
  rescue ActiveRecord::RecordNotUnique
    retry
  end

  def self.generate_id
    random_number = SecureRandom.random_number(MAX_NUMBER)
    yield Base32::Crockford.encode(random_number, length: 8)
  end
end
