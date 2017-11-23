class Rejection < ActiveRecord::Base
  class Reason
    include ActiveModel::Model
    attr_accessor :explanation

    def eql?(other)
      other.explanation.eql?(explanation)
    end

    def hash
      explanation.hash
    end
  end
end
