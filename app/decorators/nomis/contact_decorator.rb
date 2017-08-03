class Nomis::ContactDecorator < Draper::Decorator
  delegate_all

  def full_name_and_dob
    [
      "#{surname}, #{given_name}",
      date_of_birth&.to_s(:short_nomis)
    ].compact.join(' - ')
  end

  def to_data_attributes
    { uid: id, banned: banned? }
  end
end
