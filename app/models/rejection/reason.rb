# frozen_string_literal: true
class Rejection < ActiveRecord::Base
  class Reason
    include ActiveModel::Model
    attr_accessor :explanation
  end
end
