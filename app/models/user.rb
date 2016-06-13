class User < ActiveRecord::Base
  devise :database_authenticatable, :rememberable, :validatable

  belongs_to :estate
end
