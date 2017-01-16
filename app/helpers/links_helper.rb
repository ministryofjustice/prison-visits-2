# frozen_string_literal: true
module LinksHelper
  def address_book
    Rails.configuration.address_book
  end

  def link_directory
    Rails.configuration.link_directory
  end
end
