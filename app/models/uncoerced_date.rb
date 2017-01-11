# frozen_string_literal: true
class UncoercedDate
  include ActiveModel::Model
  attr_accessor :year, :month, :day
end
