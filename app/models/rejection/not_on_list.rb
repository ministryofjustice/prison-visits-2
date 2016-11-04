require 'rejection/reason'
class Rejection < ActiveRecord::Base
  class NotOnList < Reason
  end
end
